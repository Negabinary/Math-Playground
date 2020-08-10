extends VBoxContainer
class_name WPBParent

var proof_step : ProofStep
var active_dependency_id : int
var active_dependency : ProofStep

var ui_statement

var selection_handler:SelectionHandler

func _find_ui_elements() -> void:
	ui_statement = $Statement


func initialise(proof_step:ProofStep, selection_handler:SelectionHandler, active_dependency_id:=-1):
	_find_ui_elements()
	self.proof_step = proof_step
	self.selection_handler = selection_handler
	selection_handler.connect("proof_step_changed", self, "_on_selected_proof_step_changed")
	_update_statement()



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
