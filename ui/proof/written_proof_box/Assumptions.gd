extends VBoxContainer
class_name Assumptions

const scene_cell_definition := preload("res://ui/proof/assumptions/ProofDefinition.tscn")
const scene_cell_assumption := preload("res://ui/proof/assumptions/ProofAssumption.tscn")

var requirement:Requirement
var inner_proof_box:SymmetryBox
var selection_handler:SelectionHandler

func display_assumptions(requirement:Requirement, inner_proof_box:SymmetryBox, selection_handler:SelectionHandler):
	self.requirement = requirement
	self.inner_proof_box = inner_proof_box
	self.selection_handler = selection_handler
	for definition in requirement.get_definitions():
		definition.connect("updated", self, "_update_assumptions")
	_update_assumptions()

func _update_assumptions():
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var definitions:Array = requirement.get_definitions()
	for definition in definitions:
		var nc = scene_cell_definition.instance()
		nc.initialise(definition)
		add_child(nc)
	var assumptions:Array = requirement.get_assumptions()
	for assumption in assumptions:
		var nc  = scene_cell_assumption.instance()
		nc.initialise(assumption, inner_proof_box, selection_handler)
		add_child(nc)

func has_assumptions():
	return get_child_count() != 0
