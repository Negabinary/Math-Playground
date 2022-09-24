extends PanelContainer
class_name NotebookCell

signal request_delete # TODO
signal request_move_up # TODO
signal request_move_down # TODO
signal update

onready var scene_cell_definition := load("res://ui/notebook/cell/CellDefinition.tscn")
onready var scene_cell_assumption := load("res://ui/notebook/cell/CellAssumption.tscn")
onready var scene_cell_show := load("res://ui/notebook/cell/CellShow.tscn")
onready var scene_cell_import := load("res://ui/notebook/cell/CellImport.tscn")


var top_proof_box:SymmetryBox = SymmetryBox.new(
	ReparentableJustificationBox.new(
		RootJustificationBox.new()
	),
	ReparentableParseBox.new(
		RootParseBox.new()
	)
)
signal bottom_proof_box_changed
var bottom_proof_box := top_proof_box
var selection_handler : SelectionHandler


func _ready():
	$"%EditButton".connect("pressed", self, "edit")
	$"%ParseButton".connect("pressed", self, "_on_parse_button")
	$"%ReParseConfirmation".connect("confirmed", self, "_on_parse_confirmed")
	$"%CancelButton".connect("pressed", self, "cancel")
	$"%UpButton".connect("pressed", self, "_on_request_move_up_button")
	$"%DownButton".connect("pressed", self, "_on_request_move_down_button")
	$"%DeleteButton".connect("pressed", self, "_on_request_delete_button")
	$"%Enter".syntax_highlighting = true
	$"%Enter".clear_colors()
	var keywords = [
		'import', 'define', 'assume', 'show', 'forall', 'exists', 'fun', 'if', 'then', 
		'_import_', '_define_', "_import_", "_define_", "_assume_", "_show_", "_forall_", 
		"_exists_", "_fun_", "_if_", "_then_", "_->_", "as","and", "or", ":", ".", "=", ","
	]
	for keyword in keywords:
		$"%Enter".add_keyword_color(keyword, Color("#2A9D8F"))


func serialise() -> Dictionary:
	var dict = {
		string = $"%Enter".text,
		compiled = $"%Use".visible,
	}
	if $"%Use".visible:
		dict["items"] = []
		for child in $"%Use".get_children():
			dict["items"].append(child.serialise())
	return dict


func set_top_proof_box(tpb:SymmetryBox) -> void:
	self.top_proof_box.get_justification_box().set_parent(tpb.get_justification_box())
	self.top_proof_box.get_parse_box().set_parent(tpb.get_parse_box())
	$VBoxContainer/Tree.text = PoolStringArray(tpb.get_parse_box().get_all_types().get_all_names()).join(";  ")


func deserialise(json:Dictionary, context, version) -> void:
	$"%Enter".text = json.string
	if json.compiled:
		$"%Edit".hide()
		$"%Use".show()
		$"%ParseButton".hide()
		for item in json.items:
			var nc : Node
			if item.kind == "definition":
				nc = scene_cell_definition.instance()
				nc.read_only = false
			elif item.kind == "assumption":
				nc = scene_cell_assumption.instance()
			elif item.kind == "theorem":
				nc = scene_cell_show.instance()
			elif item.kind == "import":
				nc = scene_cell_import.instance()
			$"%Use".add_child(nc)
			nc.deserialise(item, context, version, selection_handler)
			context = nc.item.get_next_proof_box()
		bottom_proof_box = context
		$"%EditButton".show()


func get_bottom_proof_box() -> SymmetryBox:
	return bottom_proof_box


func _input(event):
	if $"%Enter".has_focus():
		if event.is_action_pressed("enter"):
			get_tree().set_input_as_handled()
			eval()


func eval():
	var string:String = $"%Enter".text
	var parse_result := Parser2.create_items(top_proof_box, string)
	if parse_result.error:
		$"%Error".text = str(parse_result)
	elif parse_result.items.size() == 0:
		pass
	else:
		$"%ParseButton".hide()
		$"%Edit".hide()
		for child in $"%Use".get_children():
			$"%Use".remove_child(child)
			child.queue_free()
		for item in parse_result.items:
			var nc : Node
			if item is ModuleItem2Definition:
				nc = scene_cell_definition.instance()
				$"%Use".add_child(nc)
				nc.read_only = false
				nc.initialise(item)
			elif item is ModuleItem2Assumption:
				nc = scene_cell_assumption.instance()
				$"%Use".add_child(nc)
				nc.initialise(item, selection_handler)
			elif item is ModuleItem2Theorem:
				nc = scene_cell_show.instance()
				$"%Use".add_child(nc)
				nc.initialise(item, selection_handler)
			elif item is ModuleItem2Import:
				nc = scene_cell_import.instance()
				$"%Use".add_child(nc)
				nc.initialise(item, selection_handler)
		$"%Use".show()
		$"%EditButton".show()
		bottom_proof_box = parse_result.proof_box
		emit_signal("bottom_proof_box_changed")


func cancel():
	$"%Edit".hide()
	$"%ParseButton".hide()


func edit(notify=true):
	$"%EditButton".hide()
	$"%ParseButton".show()
	$"%Edit".show()
	if notify:
		emit_signal("update")


func _on_parse_button():
	if $"%Use".visible:
		$"%ReParseConfirmation".popup_centered()
	else:
		eval()


func _on_parse_confirmed():
	eval()


func _on_request_delete_button():
	emit_signal("request_delete")


func _on_request_move_up_button():
	emit_signal("request_move_up")


func _on_request_move_down_button():
	emit_signal("request_move_down")
