extends WPBParent

var ui_contrapositive_button
var ui_implication_button
var ui_vacuous_button
var ui_reflexive_button
var ui_matching_button


func initialise(proof_step:ProofStep, selection_handler:SelectionHandler, active_dependency_id:=-1):
	selection_handler.change_selection(proof_step, Locator.new(proof_step.get_statement().as_expr_item()))
	.initialise(proof_step, selection_handler, active_dependency_id)
	ui_statement.connect("selection_changed", selection_handler, "change_locator")
	_update_justification_box()


func _update_justification_box():
	ui_implication_button = $Ideas/PanelContainer/VBoxContainer/ImplicationButton
	ui_vacuous_button = $Ideas/PanelContainer/VBoxContainer/VacuousButton
	ui_contrapositive_button = $Ideas/PanelContainer/VBoxContainer/ContrapositiveButton
	ui_reflexive_button = $Ideas/PanelContainer/VBoxContainer/ReflexivityButton
	ui_reflexive_button.visible = false
	ui_matching_button = $Ideas/PanelContainer/VBoxContainer/MatchingButton
	ui_matching_button.visible = false
	
	var parent_type:ExprItemType = proof_step.get_statement().as_expr_item().get_type()
	
	$Ideas/PanelContainer/VBoxContainer/Label2.visible = false
	
	if parent_type == GlobalTypes.IMPLIES or parent_type == GlobalTypes.FORALL:
		$Ideas/PanelContainer/VBoxContainer/Label2.visible = true
		ui_implication_button.connect("pressed", self, "_implication_button")
		ui_vacuous_button.connect("pressed", self, "_vacuous_button")
		ui_contrapositive_button.connect("pressed", self, "_contrapositive_button")
		ui_reflexive_button.visible = false
	elif parent_type == GlobalTypes.EQUALITY:
		ui_implication_button.visible = false
		ui_vacuous_button.visible = false
		ui_contrapositive_button.visible = false
		
		if proof_step.get_statement().as_expr_item().get_child(0).compare(proof_step.get_statement().as_expr_item().get_child(1)):
			$Ideas/PanelContainer/VBoxContainer/Label2.visible = true
			ui_reflexive_button.visible = true
			ui_reflexive_button.connect("pressed", self, "_reflexive_button")
		
		if proof_step.get_statement().as_expr_item().get_child(0).get_type() == proof_step.get_statement().as_expr_item().get_child(1).get_type() and \
				proof_step.get_statement().as_expr_item().get_child(0).get_child_count() == proof_step.get_statement().as_expr_item().get_child(1).get_child_count():
			$Ideas/PanelContainer/VBoxContainer/Label2.visible = true
			ui_matching_button.visible = true
			ui_matching_button.connect("pressed", self, "_matching_button")
	else:
		ui_implication_button.visible = false
		ui_vacuous_button.visible = false
		ui_contrapositive_button.visible = false
		ui_reflexive_button.visible = false


func _implication_button():
	proof_step.justify_with_implication()


func _vacuous_button():
	proof_step.justify_with_vacuous()


func _contrapositive_button():
	proof_step.justify_with_contrapositive()


func _reflexive_button():
	proof_step.justify_with_reflexivity()


func _matching_button():
	proof_step.justify_with_matching()
