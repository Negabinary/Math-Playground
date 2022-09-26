extends PanelContainer
class_name NotebookCell

signal request_delete
signal request_move_up
signal request_move_down
var selection_handler : SelectionHandler


func _ready():
	$"%EditButton".connect("pressed", self, "show_edit_area")
	$"%ParseButton".connect("pressed", self, "_on_parse_button")
	$"%ReParseConfirmation".connect("confirmed", self, "_on_parse_confirmed")
	$"%CancelButton".connect("pressed", self, "hide_edit_area")
	$"%UpButton".connect("pressed", self, "emit_signal", ["request_move_up"])
	$"%DownButton".connect("pressed", self, "emit_signal", ["request_move_down"])
	$"%DeleteButton".connect("pressed", self, "emit_signal", ["request_delete"])
	$"%Enter".syntax_highlighting = true
	$"%Enter".clear_colors()
	var keywords = [
		'import', 'define', 'assume', 'show', 'forall', 'exists', 'fun', 'if', 'then', 
		'_import_', '_define_', "_import_", "_define_", "_assume_", "_show_", "_forall_", 
		"_exists_", "_fun_", "_if_", "_then_", "_->_", "as","and", "or", ":", ".", "=", ","
	]
	for keyword in keywords:
		$"%Enter".add_keyword_color(keyword, Color("#2A9D8F"))
	
	$"%Button".connect("pressed", self, "_test_types")
	top_proof_box.get_parse_box().connect("update_rescues", self, "_on_update_rescues")


# Previous Cell ============================================

var previous_cell : NotebookCell
var top_j_box := ReparentableJustificationBox.new(GlobalTypes.get_root_symmetry().get_justification_box())
var top_p_box := ReparentableParseBox.new(GlobalTypes.get_root_symmetry().get_parse_box())
var top_proof_box := SymmetryBox.new(top_j_box, top_p_box)


func set_previous_cell(new_previous:NotebookCell):
	if previous_cell:
		previous_cell.disconnect("bottom_proof_box_changed", self, "_set_top_proof_box")
		previous_cell.disconnect("request_absolve_responsibility", self, "take_responsibility")
	previous_cell = new_previous
	_set_top_proof_box()
	if previous_cell:
		previous_cell.connect("bottom_proof_box_changed", self, "_set_top_proof_box")
		previous_cell.connect("request_absolve_responsibility", self, "take_responsibility")


func _get_previous_proof_box() -> SymmetryBox:
	if previous_cell == null:
		return GlobalTypes.get_root_symmetry()
	else:
		return previous_cell.get_bottom_proof_box()


func _set_top_proof_box() -> void:
	var tpb := _get_previous_proof_box()
	top_j_box.set_parent(tpb.get_justification_box())
	top_p_box.set_parent(tpb.get_parse_box())


# Rescue Area =============================================

signal request_absolve_responsibility # (Array<ExprItemType>,Array<String>)

func _on_update_rescues():
	var rescues:Array = top_proof_box.get_parse_box().get_rescue_types()
	var rescue_names:Array = top_proof_box.get_parse_box().get_rescue_types_old_names()
	var census := take_type_census(TypeCensus.new())
	var desired_types := []
	var desired_names := []
	var unwanted_types := []
	var unwanted_names := []
	for rid in rescues.size():
		if census.has_type(rescues[rid]):
			desired_types.append(rescues[rid])
			desired_names.append(rescue_names[rid])
		else:
			unwanted_types.append(rescues[rid])
			unwanted_names.append(rescue_names[rid])
	emit_signal("request_absolve_responsibility", unwanted_types, unwanted_names)
	if rescue_names.size() > 0:
		$"%MissingTypesOverview".text = str(rescue_names)
		if not $"%SuspensionPostit".visible:
			$"%SuspensionPostit".show()
			$"%Scribble".show()
			emit_signal("bottom_proof_box_changed")
	else:
		if $"%SuspensionPostit".visible:
			$"%SuspensionPostit".hide()
			$"%Scribble".hide()
			emit_signal("bottom_proof_box_changed")

func take_responsibility(rescue, rescue_name):
	top_proof_box.get_parse_box().take_responsibility_for(rescue, rescue_name)

func is_suspended() -> bool:
	return $"%Scribble".visible


# Edit Area ===============================================

func hide_edit_area() -> void:
	$"%Edit".hide()
	$"%ParseButton".hide()
	$"%EditButton".show()


func show_edit_area(allow_cancel:=true) -> void:
	$"%EditButton".hide()
	$"%ParseButton".show()
	$"%CancelButton".visible = allow_cancel
	$"%Edit".show()


func eval():
	var string:String = $"%Enter".text
	var parse_result := Parser2.create_items(top_proof_box, string)
	if parse_result.error:
		$"%Error".text = str(parse_result)
	elif parse_result.items.size() == 0:
		$"%Error".text = "Section empty!"
	else:
		hide_edit_area()
		$"%UseArea".set_items(parse_result.items)
		emit_signal("bottom_proof_box_changed")


func _input(event):
	if $"%Enter".has_focus():
		if event.is_action_pressed("enter"):
			get_tree().set_input_as_handled()
			eval()


func _on_parse_button():
	if $"%UseArea".visible:
		$"%ReParseConfirmation".popup_centered()
	else:
		eval()


func _on_parse_confirmed():
	eval()


# Use Area ================================================

func take_type_census(census:TypeCensus) -> TypeCensus:
	var children := $"%Use".get_children()
	children.invert()
	for item in children:
		item.take_type_census(census)
	return census

signal bottom_proof_box_changed

func get_bottom_proof_box() -> SymmetryBox:
	if is_suspended():
		return _get_previous_proof_box()
	else:
		var result = $"%UseArea".get_bottom_proof_box()
		if result:
			return result
		else:
			return top_proof_box


# Button Actions ==========================================


func _test_types():
	var census2 = top_proof_box.get_parse_box().type_to_listeners.keys()
	var census := take_type_census(TypeCensus.new())
	$"%TypeTester".text = census.print_result(top_proof_box.get_parse_box())
	$"%TypeTester".text += "\n" + str(census2)


# Serialization ===========================================

func serialise() -> Dictionary:
	var dict = {
		string = $"%Enter".text,
		compiled = $"%UseArea".visible,
		title = $"%Title".text
	}
	if $"%UseArea".visible:
		dict["items"] = []
		for child in $"%Use".get_children():
			dict["items"].append(child.serialise())
	return dict


func deserialise(json:Dictionary, version) -> void:
	$"%Enter".text = json.string
	$"%Title".text = json.get("title","")
	if json.compiled:
		hide_edit_area()
		$"%UseArea".deserialise(json.items, top_proof_box, version)
		emit_signal("bottom_proof_box_changed")
