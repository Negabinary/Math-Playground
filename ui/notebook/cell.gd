extends PanelContainer
class_name NotebookCell

signal request_delete # TODO
signal request_move_up # TODO
signal request_move_down # TODO
signal request_absolve_responsibility # (Array<ExprItemType>,Array<String>)


var previous_proof_box:SymmetryBox = SymmetryBox.new(
	RootJustificationBox.new(),
	RootParseBox.new()
)
var rescue_types : Array = []
var top_proof_box:SymmetryBox = SymmetryBox.new(
	ReparentableJustificationBox.new(
		previous_proof_box.get_justification_box()
	),
	ReparentableParseBox.new(
		previous_proof_box.get_parse_box()
	)
)
var bottom_rescue_types := []
var bottom_proof_box := top_proof_box
signal bottom_proof_box_changed


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


# API =====================================================

func set_top_proof_box(tpb:SymmetryBox) -> void:
	self.top_proof_box.get_justification_box().set_parent(tpb.get_justification_box())
	self.top_proof_box.get_parse_box().set_parent(tpb.get_parse_box())


func get_bottom_proof_box() -> SymmetryBox:
	return bottom_proof_box


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
		bottom_proof_box = parse_result.proof_box
		emit_signal("bottom_proof_box_changed")


func take_type_census(census:TypeCensus) -> TypeCensus:
	var children := $"%Use".get_children()
	children.invert()
	for item in children:
		item.take_type_census(census)
	return census


# Button Actions ==========================================

func _input(event):
	if $"%Enter".has_focus():
		if event.is_action_pressed("enter"):
			get_tree().set_input_as_handled()
			eval()


func _on_parse_button():
	if $"%Use".visible:
		$"%ReParseConfirmation".popup_centered()
	else:
		eval()


func _on_parse_confirmed():
	eval()


func _test_types():
	var census2 = top_proof_box.get_parse_box().type_to_listeners.keys()
	var census := take_type_census(TypeCensus.new())
	$"%TypeTester".text = census.print_result(top_proof_box.get_parse_box())
	$"%TypeTester".text += "\n" + str(census2)

# Rescues =================================================

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
	$"%Rescues".text = str(rescue_names)

func take_responsibility(rescue, rescue_name):
	top_proof_box.get_parse_box().take_responsibility_for(rescue, rescue_name)

# Serialization ===========================================

func serialise() -> Dictionary:
	var dict = {
		string = $"%Enter".text,
		compiled = $"%UseArea".visible,
	}
	if $"%UseArea".visible:
		dict["items"] = []
		for child in $"%Use".get_children():
			dict["items"].append(child.serialise())
	return dict


func deserialise(json:Dictionary, version) -> void:
	$"%Enter".text = json.string
	if json.compiled:
		hide_edit_area()
		bottom_proof_box = $"%UseArea".deserialise(json.items, top_proof_box, version)
		emit_signal("bottom_proof_box_changed")
