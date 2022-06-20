extends ColorRect
class_name Notebook

const cell = preload("res://ui/notebook/cell/Cell.tscn")

onready var ui_cells := $HSplitContainer/Container/ScrollContainer/MarginContainer/VBoxContainer/Cells
onready var ui_new_cell_button := $HSplitContainer/Container/ScrollContainer/MarginContainer/VBoxContainer/NewCell


func _ready():
	ui_new_cell_button.connect("pressed", self, "new_cell")

func new_cell(json = null, proof_box = null, version = 0):
	var node := cell.instance()
	ui_cells.add_child(node)
	if json != null:
		node.deserialise(json, proof_box, version)	
	node.connect("request_delete", self, "delete_cell", [node])
	node.connect("request_move_up", self, "move_cell_up", [node])
	node.connect("request_move_down", self, "move_cell_down", [node])
	if json == null:
		_recompile_from(node.get_index())

func move_cell_up(cell:NotebookCell):
	if cell.get_index() > 0:
		ui_cells.move_child(cell, cell.get_index() - 1)
		_recompile_from(cell.get_index())

func move_cell_down(cell:NotebookCell):
	if cell.get_index() < ui_cells.get_child_count() - 1:
		ui_cells.move_child(cell, cell.get_index() + 1)
		_recompile_from(cell.get_index() - 1)

func delete_cell(cell:NotebookCell):
	var idx := cell.get_index()
	ui_cells.remove_child(cell)
	_recompile_from(idx)

func _recompile_from(idx:int, to=ui_cells.get_child_count()):
	for i in range(idx, to):
		ui_cells.get_child(i).set_top_proof_box(_get_proof_box_before(i))

func _get_proof_box_before(idx:int):
	if idx == 0:
		return GlobalTypes.PROOF_BOX
	else:
		return ui_cells.get_child(idx-1).get_bottom_proof_box()

func clear() -> void:
	Module2Loader.clear()
	for child in ui_cells.get_children():
		ui_cells.remove_child(child)

func deserialise(json:Dictionary) -> void:
	clear()
	for i in len(json.cells):
		new_cell(json.cells[i], _get_proof_box_before(i), json.version if json.version else 0)

func serialise() -> Dictionary:
	var cell_obj := []
	for cell in ui_cells.get_children():
		cell_obj.append(cell.serialise())
	return {cells=cell_obj, version=30}
