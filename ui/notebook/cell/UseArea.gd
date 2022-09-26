extends MarginContainer

onready var scene_cell_definition := load("res://ui/notebook/cell/CellDefinition.tscn")
onready var scene_cell_assumption := load("res://ui/notebook/cell/CellAssumption.tscn")
onready var scene_cell_show := load("res://ui/notebook/cell/CellShow.tscn")
onready var scene_cell_import := load("res://ui/notebook/cell/CellImport.tscn")

onready var selection_handler : SelectionHandler = get_tree().get_nodes_in_group("selection_handler")[0]


func set_items(items:Array):
	for child in $"%Use".get_children():
		$"%Use".remove_child(child)
		child.queue_free()
	for item in items:
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
	show()
	$"%Scribble".hide()


func deserialise(json_items:Array, context, version):
	for item in json_items:
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
	show()
	$"%Scribble".hide()
	return context
