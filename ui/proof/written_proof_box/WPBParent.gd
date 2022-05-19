extends VBoxContainer
class_name WPBParent

var inner_proof_box : ProofBox
var requirement : Requirement
var ui_statement : WrittenStatement

var selection_handler

func _find_ui_elements() -> void:
	ui_statement = $Statement


func initialise(context:ProofBox, requirement:Requirement, selection_handler):
	_find_ui_elements()
	self.inner_proof_box = ProofBox.new(context, requirement.get_definitions(), requirement.get_assumptions())
	self.requirement = requirement
	self.selection_handler = selection_handler
	selection_handler.connect("locator_changed", self, "_on_locator_changed")
	ui_statement.connect("selection_changed", self, "_on_selection_changed")
	_update_statement()


func get_selected_locator() -> Locator:
	return ui_statement.get_locator()


func _on_locator_changed(x):
	if selection_handler.get_wpb() != self:
		ui_statement.deselect()


func _on_selection_changed(x):
	selection_handler.take_selection(self)
	


func _conditions_met():
	var requirements := proof_step.get_requirements()
	var conditions_met := true
	for requirement in requirements:
		if requirement != active_dependency:
			if not requirement.is_proven():
				conditions_met = false
	return conditions_met


func _update_statement():
	ui_statement.set_expr_item(requirement.get_goal())


func _draw():
	pass
