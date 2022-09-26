extends Control
class_name Notebook

const cell = preload("res://ui/notebook/cell/Cell.tscn")

onready var ui_new_cell_button := $"%NewCell"
onready var selection_handler := $SelectionHandler

var top_symmetry_box := GlobalTypes.get_root_symmetry()


func _ready():
	ui_new_cell_button.connect("pressed", self, "new_cell", [null])


func new_cell(json = null, version = 0) -> void:
	var node := cell.instance()
	node.selection_handler = selection_handler
	$"%Cells".add_child(node)
	node.set_top_proof_box(_get_proof_box_before($"%Cells".get_child_count() - 1))
	if json != null:
		node.deserialise(json, version)	
	node.connect("request_delete", self, "delete_cell", [node])
	node.connect("request_move_up", self, "move_cell_up", [node])
	node.connect("request_move_down", self, "move_cell_down", [node])
	node.connect("bottom_proof_box_changed", self, "_update_pb_after", [node])
	node.connect("request_absolve_responsibility", self, "_on_request_absolve", [node])


func _on_request_absolve(types:Array, names:Array, cell:NotebookCell):
	var idx:int = cell.get_index()
	if $"%Cells".get_child_count() > (idx + 1):
		var next = $"%Cells".get_child(idx + 1)
		next.take_responsibility(types, names)
	

func move_cell_up(cell:NotebookCell) -> void:
	if cell.get_index() > 0:
		var previous_cell = $"%Cells".get_child(cell.get_index() - 1)
		cell.set_top_proof_box(_get_proof_box_before(previous_cell.get_index()))
		$"%Cells".move_child(cell, cell.get_index() - 1)
		previous_cell.set_top_proof_box(cell.get_bottom_proof_box())
		if previous_cell.get_index() < $"%Cells".get_child_count() - 1:
			var next_cell = $"%Cells".get_child(previous_cell.get_index() + 1)
			next_cell.set_top_proof_box(previous_cell.get_bottom_proof_box())


func move_cell_down(cell:NotebookCell) -> void:
	if cell.get_index() < $"%Cells".get_child_count() - 1:
		move_cell_up($"%Cells".get_child(cell.get_index() + 1))


func delete_cell(cell:NotebookCell) -> void:
	var idx := cell.get_index()
	$"%Cells".remove_child(cell)
	if idx < $"%Cells".get_child_count():
		$"%Cells".get_child(idx).set_top_proof_box(_get_proof_box_before(idx))
	cell.set_top_proof_box(top_symmetry_box)
	cell.queue_free()


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
		new_cell(json.cells[i], json.version if "version" in json else 0)


func serialise() -> Dictionary:
	var cell_obj := []
	for cell in $"%Cells".get_children():
		cell_obj.append(cell.serialise())
	return {cells=cell_obj, version=30}
