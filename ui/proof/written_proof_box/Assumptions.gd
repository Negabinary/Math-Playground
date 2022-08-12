extends VBoxContainer
class_name Assumptions

const scene_cell_definition := preload("res://ui/notebook/cell/CellDefinition.tscn")
const scene_cell_assumption := preload("res://ui/notebook/cell/CellAssumption.tscn")

var requirement:Requirement
var inner_proof_box:SymmetryBox
var selection_handler:SelectionHandler

func display_assumptions(requirement:Requirement, inner_proof_box:SymmetryBox, selection_handler:SelectionHandler):
	self.requirement = requirement
	self.inner_proof_box = inner_proof_box
	self.selection_handler = selection_handler
	for definition in requirement.get_definitions():
		definition.connect("renamed", self, "_update_assumptions")
	_update_assumptions()

func _update_assumptions():
	for child in get_children():
		remove_child(child)
	var definitions:Array = requirement.get_definitions()
	for definition in definitions:
		var nc = scene_cell_definition.instance()
		nc.initialise(ModuleItem2Definition.new(
			inner_proof_box, 
			definition
		))
		add_child(nc)
	var assumptions:Array = requirement.get_assumptions()
	for assumption in assumptions:
		var nc  = scene_cell_assumption.instance()
		nc.initialise(
			ModuleItem2Assumption.new(
				inner_proof_box,
				assumption
			),
			selection_handler
		)
		add_child(nc)

func has_assumptions():
	return get_child_count() != 0
