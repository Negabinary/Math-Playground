extends Control
class_name Notebook

const cell = preload("res://ui/notebook/cell/Cell.tscn")

onready var ui_new_cell_button := $"%NewCell"
onready var selection_handler := $SelectionHandler

var top_symmetry_box := GlobalTypes.get_root_symmetry()


func _ready():
	ui_new_cell_button.connect("pressed", self, "new_cell", [null])


func new_cell(json = null, proof_box = null, version = 0) -> void:
	var node := cell.instance()
	node.selection_handler = selection_handler
	$"%Cells".add_child(node)
	node.set_top_proof_box(_get_proof_box_before($"%Cells".get_child_count() - 1))
	if json != null:
		node.deserialise(json, proof_box, version)	
	node.connect("request_delete", self, "delete_cell", [node])
	node.connect("request_move_up", self, "move_cell_up", [node])
	node.connect("request_move_down", self, "move_cell_down", [node])
	node.connect("bottom_proof_box_changed", self, "_update_pb_after", [node])


func move_cell_up(cell:NotebookCell) -> void:
	if cell.get_index() > 0:
		var previous_cell = $"%Cells".get_child(cell.get_index() - 1)
		$"%Cells".move_child(cell, cell.get_index() - 1)
		cell.set_top_proof_box(_get_proof_box_before(cell.get_index()))
		previous_cell.set_top_proof_box(cell.get_bottom_proof_box())


func move_cell_down(cell:NotebookCell) -> void:
	if cell.get_index() < $"%Cells".get_child_count() - 1:
		move_cell_up($"%Cells".get_child(cell.get_index() + 1))


func delete_cell(cell:NotebookCell) -> void:
	var idx := cell.get_index()
	$"%Cells".remove_child(cell)
	cell.queue_free()
	if idx < $"%Cells".get_child_count():
		$"%Cells".get_child(idx).set_top_proof_box(_get_proof_box_before(idx))


func _update_pb_after(cell:NotebookCell) -> void:
	var idx := cell.get_index()
	if idx + 1 < $"%Cells".get_child_count():
		$"%Cells".get_child(idx+1).set_top_proof_box(cell.get_bottom_proof_box())


func _get_proof_box_before(idx:int) -> SymmetryBox:
	if idx == 0:
		return top_symmetry_box
	else:
		return $"%Cells".get_child(idx-1).get_bottom_proof_box()


func clear() -> void:
	Module2Loader.clear()
	for child in $"%Cells".get_children():
		$"%Cells".remove_child(child)
		child.queue_free()


func deserialise(json:Dictionary) -> void:
	clear()
	for i in len(json.cells):
		new_cell(json.cells[i], _get_proof_box_before(i), json.version if "version" in json else 0)


func serialise() -> Dictionary:
	var cell_obj := []
	for cell in $"%Cells".get_children():
		cell_obj.append(cell.serialise())
	return {cells=cell_obj, version=30}
