extends VBoxContainer
class_name WPBParent

var proof_step : ProofStep
var active_dependency_id : int
var active_dependency : ProofStep

var ui_statement : WrittenStatement

var selection_handler

func _find_ui_elements() -> void:
	ui_statement = $Statement


func initialise(proof_step:ProofStep, selection_handler, active_dependency_id:=-1):
	_find_ui_elements()
	self.proof_step = proof_step
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


func _on_selected_proof_step_changed(new_proof_step):
	if new_proof_step != proof_step:
		ui_statement.deselect()
	


func _conditions_met():
	var requirements := proof_step.get_requirements()
	var conditions_met := true
	for requirement in requirements:
		if requirement != active_dependency:
			if not requirement.is_proven():
				conditions_met = false
	return conditions_met


func _update_statement():
	ui_statement.set_expr_item(proof_step.get_statement().as_expr_item())


func _draw():
	pass
