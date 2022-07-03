extends WindowDialog
class_name Book

var loaded := false
var module : Module # Set by CellImport
var selection_handler : SelectionHandler # Set by CellImport


onready var ui_use_area = $ScrollContainer/BookCells

onready var scene_cell_definition := load("res://ui/notebook/cell/CellDefinition.tscn")
onready var scene_cell_assumption := load("res://ui/notebook/cell/CellAssumption.tscn")
onready var scene_cell_show := load("res://ui/notebook/cell/CellShow.tscn")
onready var scene_cell_import := load("res://ui/notebook/cell/CellImport.tscn")


func open_book():
	if not loaded:
		load_book()
	popup_centered()
	loaded = true


func load_book():
	window_title = module.get_name()
	var items := module.get_all_items()
	for item in items:
		var nc : Node
		if item is ModuleItem2Definition:
			nc = scene_cell_definition.instance()
			ui_use_area.add_child(nc)
			nc.initialise(item)
		elif item is ModuleItem2Assumption:
			nc = scene_cell_assumption.instance()
			ui_use_area.add_child(nc)
			nc.initialise(item, selection_handler)
		elif item is ModuleItem2Theorem:
			var assumption_version = item.get_as_assumption()
			nc = scene_cell_assumption.instance()
			ui_use_area.add_child(nc)
			nc.initialise(assumption_version, selection_handler)
		elif item is ModuleItem2Import:
			nc = scene_cell_import.instance()
			ui_use_area.add_child(nc)
			nc.initialise(item, selection_handler)
