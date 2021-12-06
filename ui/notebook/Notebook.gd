extends ColorRect

const cell = preload("res://ui/notebook/cell/Cell.tscn")

onready var ui_cells := $HSplitContainer/Container/ScrollContainer/MarginContainer/VBoxContainer/Cells
onready var ui_new_cell_button := $HSplitContainer/Container/ScrollContainer/MarginContainer/VBoxContainer/NewCell


func _ready():
	ui_new_cell_button.connect("pressed", self, "new_cell")

func new_cell():
	var node := cell.instance()
	ui_cells.add_child(node)
	node.connect("request_delete", self, "delete_cell", [node])
	node.connect("request_move_up", self, "move_cell_up", [node])
	node.connect("request_move_down", self, "move_cell_down", [node])
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

func _recompile_from(idx:int):
	for i in range(idx, ui_cells.get_child_count()):
		if i == 0:
			ui_cells.get_child(i).set_top_proof_box(GlobalTypes.PROOF_BOX)
		else:
			ui_cells.get_child(i).set_top_proof_box(
				ui_cells.get_child(i-1).get_bottom_proof_box()
			)
