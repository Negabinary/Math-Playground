extends WPBParent

var ui_contrapositive_button
var ui_implication_button
var ui_vacuous_button
var ui_reflexive_button
var ui_matching_button
var ui_custom_forall_button
var ui_custom_implication_button
var ui_create_lambda_button
var ui_destroy_lambda_button


func _ready():
	$Ideas/PanelContainer/VBoxContainer/CustomForAllButton/NewIdentifierNameDialog.connect("confirmed", self, "_on_custom_forall_confirm")
	$Ideas/PanelContainer/VBoxContainer/CustomImplicationButton/NewImplicationDialog.connect("confirmed", self, "_on_custom_implication_confirm")
	$Ideas/PanelContainer/VBoxContainer/CreateLamdaButton/WindowDialog.connect("confirmed",self,"_on_create_lambda_confirm")


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
	ui_custom_forall_button = $Ideas/PanelContainer/VBoxContainer/CustomForAllButton
	ui_custom_forall_button.visible = true
	ui_custom_forall_button.connect("pressed", self, "_custom_forall_button")
	ui_custom_implication_button = $Ideas/PanelContainer/VBoxContainer/CustomImplicationButton
	ui_custom_implication_button.visible = true
	ui_custom_implication_button.connect("pressed", self, "_custom_implication_button")
	ui_create_lambda_button = $Ideas/PanelContainer/VBoxContainer/CreateLamdaButton
	ui_create_lambda_button.visible = true
	ui_create_lambda_button.connect("pressed", self, "_create_lambda_button")
	ui_destroy_lambda_button = $Ideas/PanelContainer/VBoxContainer/DestroyLambdaButton
	ui_destroy_lambda_button.connect("pressed", self, "_destroy_lambda_button")
	ui_destroy_lambda_button.visible = selection_handler.get_locator().get_type() == GlobalTypes.LAMBDA
	selection_handler.connect("locator_changed", self, "_on_locator_changed")
	
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


func _on_locator_changed(locator:Locator):
	ui_destroy_lambda_button.visible = (locator != null) && (locator.get_type() == GlobalTypes.LAMBDA) && (locator.get_child_count() >= 3)


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


func _custom_forall_button():
	ui_custom_forall_button.get_node("NewIdentifierNameDialog").popup()


func _create_lambda_button():
	var locator
	if selection_handler.get_proof_step() == proof_step:
		locator = selection_handler.get_locator()
	else:
		locator = Locator.new(proof_step.get_statement().as_expr_item())
	ui_create_lambda_button.get_node("WindowDialog").pop_up(proof_step, locator)


func _destroy_lambda_button():
	proof_step.justify_with_destroy_lambda(selection_handler.get_locator())


func _on_custom_forall_confirm():
	proof_step.justify_with_generalisation(ui_custom_forall_button.get_node("NewIdentifierNameDialog/LineEdit").text)


func _custom_implication_button():
	ui_custom_implication_button.get_node("NewImplicationDialog").pop_up(proof_step.get_proof_box())


func _on_custom_implication_confirm():
	JustificationBuilder.custom_implication(proof_step, $Ideas/PanelContainer/VBoxContainer/CustomImplicationButton/NewImplicationDialog/CenterContainer/ExprItemEdit.get_expr_item())


func _on_create_lambda_confirm():
	var create_lambda = $Ideas/PanelContainer/VBoxContainer/CreateLamdaButton/WindowDialog/CreateLambda
	proof_step.justify_with_create_lambda(create_lambda.get_locator(), create_lambda.get_argument_locations(), create_lambda.get_argument_types(), create_lambda.get_argument_values())
