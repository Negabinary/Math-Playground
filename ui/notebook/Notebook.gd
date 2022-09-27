extends Control
class_name Notebook

const CELL_SCENE = preload("res://ui/notebook/cell/Cell.tscn")

onready var ui_new_cell_button := $"%NewCell"
onready var selection_handler := $SelectionHandler


func _ready():
	ui_new_cell_button.connect("pressed", self, "new_cell", [null])


func new_cell(json = null, version = 0) -> void:
	var node := CELL_SCENE.instance()
	node.selection_handler = selection_handler
	$"%Cells".add_child(node)
	node.set_previous_cell(_get_cell_before($"%Cells".get_child_count() - 1))
	if json != null:
		node.deserialise(json, version)	
	node.connect("request_delete", self, "delete_cell", [node])
	node.connect("request_move_up", self, "move_cell_up", [node])
	node.connect("request_move_down", self, "move_cell_down", [node])
	node.connect("request_absolve_responsibility", self, "_on_request_absolve", [node])


func move_cell_up(cell:NotebookCell) -> void:
	if cell.get_index() > 0:
		var previous_cell = $"%Cells".get_child(cell.get_index() - 1)
		$"%Cells".move_child(cell, cell.get_index() - 1)
		var r := range(
			cell.get_index(),
			min($"%Cells".get_child_count(), cell.get_index() + 3)
		)
		for i in r:
			$"%Cells".get_child(i).set_previous_cell(_get_cell_before(i))


func move_cell_down(cell:NotebookCell) -> void:
	if cell.get_index() < $"%Cells".get_child_count() - 1:
		move_cell_up($"%Cells".get_child(cell.get_index() + 1))


func delete_cell(cell:NotebookCell) -> void:
	var idx := cell.get_index()
	$"%Cells".remove_child(cell)
	if idx < $"%Cells".get_child_count():
		$"%Cells".get_child(idx).set_previous_cell(_get_cell_before(idx))
	cell.set_previous_cell(null)
	cell.queue_free()


func _get_cell_before(idx:int) -> NotebookCell:
	if idx == 0:
		return null
	else:
		return ($"%Cells".get_child(idx-1) as NotebookCell)


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
		if not cell.is_suspended():
			cell_obj.append(cell.serialise())
	return {cells=cell_obj, version=30}


func check_for_suspensions() -> bool:
	for cell in $"%Cells".get_children():
		if cell.is_suspended():
			return true
	return false
