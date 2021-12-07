extends PanelContainer
class_name NotebookCell

signal request_delete # TODO
signal request_move_up # TODO
signal request_move_down # TODO
signal update

onready var ui_edit_button := $VBoxContainer/HBoxContainer/EditButton
onready var ui_eval_button := $VBoxContainer/HBoxContainer/ParseButton
onready var ui_up_button = $VBoxContainer/HBoxContainer/UpButton
onready var ui_down_button = $VBoxContainer/HBoxContainer/DownButton
onready var ui_delete_button = $VBoxContainer/HBoxContainer/DeleteButton

onready var ui_entry_box:TextEdit = $VBoxContainer/Edit/Enter
onready var ui_error_box:RichTextLabel = $VBoxContainer/Edit/Error
onready var ui_edit_area = $VBoxContainer/Edit
onready var ui_use_area = $VBoxContainer/Use

onready var scene_cell_definition := load("res://ui/notebook/cell/CellDefinition.tscn")
onready var scene_cell_assumption := load("res://ui/notebook/cell/CellAssumption.tscn")
onready var scene_cell_show := load("res://ui/notebook/cell/CellShow.tscn")
onready var scene_cell_import := load("res://ui/notebook/cell/CellImport.tscn")


var top_proof_box := GlobalTypes.PROOF_BOX
var bottom_proof_box := top_proof_box


func _ready():
	ui_edit_button.connect("pressed", self, "edit")
	ui_eval_button.connect("pressed", self, "eval")
	ui_up_button.connect("pressed", self, "_on_request_move_up_button")
	ui_down_button.connect("pressed", self, "_on_request_move_down_button")
	ui_delete_button.connect("pressed", self, "_on_request_delete_button")


func set_top_proof_box(tpb:ProofBox) -> void:
	self.top_proof_box = tpb
	self.bottom_proof_box = tpb
	if ui_use_area.visible:
		edit(false)
		eval(false)
	elif ui_error_box.visible:
		eval(false)


func get_bottom_proof_box() -> ProofBox:
	return bottom_proof_box


func _input(event):
	if ui_entry_box.has_focus():
		if event.is_action_pressed("enter"):
			get_tree().set_input_as_handled()
			eval()


func eval(notify=true):
	var string := ui_entry_box.text
	var parse_result := Parser2.create_items(top_proof_box, string)
	if parse_result.error:
		ui_error_box.text = str(parse_result)
		ui_error_box.show()
	elif parse_result.items.size() == 0:
		pass
	else:
		ui_eval_button.hide()
		ui_error_box.hide()
		ui_edit_area.hide()
		for child in ui_use_area.get_children():
			ui_use_area.remove_child(child)
		for item in parse_result.items:
			var nc : Node
			if item is ModuleItem2Definition:
				nc = scene_cell_definition.instance()
				ui_use_area.add_child(nc)
				nc.initialise(item)
			elif item is ModuleItem2Assumption:
				nc = scene_cell_assumption.instance()
				ui_use_area.add_child(nc)
				nc.initialise(item)
			elif item is ModuleItem2Theorem:
				nc = scene_cell_show.instance()
				ui_use_area.add_child(nc)
				nc.initialise(item)
			elif item is ModuleItem2Import:
				nc = scene_cell_import.instance()
				ui_use_area.add_child(nc)
				nc.initialise(item)
		ui_use_area.show()
		ui_edit_button.show()
		bottom_proof_box = parse_result.proof_box
		if notify:
			emit_signal("update")


func edit(notify=true):
	ui_use_area.hide()
	ui_edit_button.hide()
	ui_eval_button.show()
	ui_edit_area.show()
	bottom_proof_box = top_proof_box
	if notify:
		emit_signal("update")


func _on_request_delete_button():
	emit_signal("request_delete")


func _on_request_move_up_button():
	emit_signal("request_move_up")


func _on_request_move_down_button():
	emit_signal("request_move_down")