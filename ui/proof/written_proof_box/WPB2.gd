extends VBoxContainer
class_name WrittenProofBox2

const WPB2:PackedScene = preload("res://ui/proof/written_proof_box/WPB2.tscn")

var inner_proof_box : ProofBox # final
var requirement : Requirement # final
var selection_handler # final

var ui_assumptions : Assumptions
var ui_dependencies : MarginContainer
var ui_justification_holder : WPBJustification
var ui_statement : WrittenStatement

var WPB_SCENE = load("res://ui/proof/written_proof_box/WPB2.tscn")


func _find_ui_elements() -> void:
	ui_assumptions = $Assumptions
	ui_dependencies = $Dependencies
	ui_justification_holder = $Justification
	ui_statement = $Statement


func init(context:ProofBox, requirement:Requirement, selection_handler):
	_find_ui_elements()
	self.requirement = requirement
	self.selection_handler = selection_handler
	self.inner_proof_box = ProofBox.new(
		context, requirement.get_definitions(), requirement.get_assumptions()
	)
	ui_statement.set_expr_item(requirement.get_goal())
	ui_justification_holder.init(requirement.get_goal(), inner_proof_box)
	ui_justification_holder.connect("justification_changed", self, "_on_justification_changed")
	_change_dependencies(ui_justification_holder.get_requirements())
	ui_assumptions.show_assumptions(requirement)


func _change_active_depenency(dependency_id:int):
	for child in ui_dependencies.get_children():
		if child.get_index() == dependency_id:
			child.show()
		else:
			child.hide()

func _on_justification_changed():
	_change_dependencies(ui_justification_holder.get_requirements())

func _change_dependencies(requirements:Array, dependency_id:=0):
	var keepers := {}
	var old_children = ui_dependencies.get_children()
	for child in ui_dependencies.get_children():
		ui_dependencies.remove_child(child)
	for new_requirement in requirements:
		for child in old_children:
			if child.requirement.compare(new_requirement):
				keepers[new_requirement] = child
				ui_dependencies.remove_child(child)
				break
		if keepers.get(new_requirement):
			ui_dependencies.add_child(keepers[new_requirement])
		else:
			var new_ui_dependency = WPB2.instance()
			new_ui_dependency.init(inner_proof_box, new_requirement, selection_handler)
			ui_dependencies.add_child(new_ui_dependency)
	_change_active_depenency(dependency_id)
