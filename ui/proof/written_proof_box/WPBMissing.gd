extends WPBParent

var ui_implication_button
var ui_vacuous_button
var ui_reflexive_button
var ui_matching_button
var ui_custom_forall_button
var ui_custom_implication_button
var ui_create_lambda_button
var ui_destroy_lambda_button
var ui_witness_button
var ui_double_negative_button


func _ready():
	$Ideas/PanelContainer/VBoxContainer/CustomForAllButton/NewIdentifierNameDialog.connect("confirmed", self, "_on_custom_forall_confirm")
	$Ideas/PanelContainer/VBoxContainer/CustomImplicationButton/NewImplicationDialog.connect("confirmed", self, "_on_custom_implication_confirm")
	$Ideas/PanelContainer/VBoxContainer/CreateLamdaButton/WindowDialog.connect("confirmed",self,"_on_create_lambda_confirm")
	$Ideas/PanelContainer/VBoxContainer/WitnessButton/WitnessDialog.connect("confirmed", self, "_on_witness_confirm")


func initialise(requirement:Requirement, selection_handler:SelectionHandler):
	.initialise(requirement, active_dependency_id)
	ui_statement.select_whole()
	selection_handler.take_selection(self)
	_update_justification_box()


func _update_justification_box():
	ui_implication_button = $Ideas/PanelContainer/VBoxContainer/ImplicationButton
	ui_vacuous_button = $Ideas/PanelContainer/VBoxContainer/VacuousButton
	ui_reflexive_button = $Ideas/PanelContainer/VBoxContainer/ReflexivityButton
	ui_reflexive_button.visible = false
	ui_matching_button = $Ideas/PanelContainer/VBoxContainer/MatchingButton
	ui_matching_button.visible = false
	ui_custom_forall_button = $Ideas/PanelContainer/VBoxContainer/CustomForAllButton
	ui_custom_forall_button.visible = false
	ui_custom_forall_button.connect("pressed", self, "_custom_forall_button")
	ui_custom_implication_button = $Ideas/PanelContainer/VBoxContainer/CustomImplicationButton
	ui_custom_implication_button.visible = false
	ui_custom_implication_button.connect("pressed", self, "_custom_implication_button")
	ui_create_lambda_button = $Ideas/PanelContainer/VBoxContainer/CreateLamdaButton
	ui_create_lambda_button.visible = false
	ui_create_lambda_button.connect("pressed", self, "_create_lambda_button")
	ui_destroy_lambda_button = $Ideas/PanelContainer/VBoxContainer/DestroyLambdaButton
	ui_destroy_lambda_button.connect("pressed", self, "_destroy_lambda_button")
	ui_double_negative_button = $Ideas/PanelContainer/VBoxContainer/DoubleNegativeButton
	ui_destroy_lambda_button.visible = selection_handler.get_locator().get_type() == GlobalTypes.LAMBDA && selection_handler.get_locator().get_child_count() >= 3
	ui_double_negative_button.connect("pressed", self, "_double_negative_button")
	var locator:Locator = selection_handler.get_locator()
	ui_double_negative_button.visible = (locator != null) && (locator.get_type() == GlobalTypes.NOT) && (locator.get_child_count() == 1) && (locator.get_child(0).get_type() == GlobalTypes.NOT)
	ui_witness_button = $Ideas/PanelContainer/VBoxContainer/WitnessButton
	ui_witness_button.connect("pressed", self, "_witness_button")
	ui_witness_button.visible = false
	
	
	var parent_type:ExprItemType = requirement.get_goal().get_type()
	
	$Ideas/PanelContainer/VBoxContainer/Label2.visible = false
	
	if parent_type == GlobalTypes.IMPLIES or parent_type == GlobalTypes.FORALL:
		$Ideas/PanelContainer/VBoxContainer/Label2.visible = true
		ui_implication_button.connect("pressed", self, "_implication_button")
		ui_vacuous_button.connect("pressed", self, "_vacuous_button")
		ui_reflexive_button.visible = false
	elif parent_type == GlobalTypes.EQUALITY:
		ui_implication_button.visible = false
		ui_vacuous_button.visible = false
		
		if requirement.get_goal().get_child(0).compare(requirement.get_goal().get_child(1)):
			$Ideas/PanelContainer/VBoxContainer/Label2.visible = true
			ui_reflexive_button.visible = true
			ui_reflexive_button.connect("pressed", self, "_reflexive_button")
		
		if requirement.get_goal().get_child(0).get_type() == requirement.get_goal().get_child(1).get_type() and \
				requirement.get_goal().get_child(0).get_child_count() == requirement.get_goal().get_child(1).get_child_count():
			$Ideas/PanelContainer/VBoxContainer/Label2.visible = true
			ui_matching_button.visible = true
			ui_matching_button.connect("pressed", self, "_matching_button")
	elif parent_type == GlobalTypes.EXISTS:
		print("HERE!!")
		ui_witness_button.show()
	else:
		ui_implication_button.visible = false
		ui_vacuous_button.visible = false
		ui_reflexive_button.visible = false


func _on_locator_changed(x):
	._on_locator_changed(x)
	ui_double_negative_button = $Ideas/PanelContainer/VBoxContainer/DoubleNegativeButton
	ui_destroy_lambda_button = $Ideas/PanelContainer/VBoxContainer/DestroyLambdaButton
	ui_destroy_lambda_button.visible = (get_selected_locator() != null) && (get_selected_locator().get_type() == GlobalTypes.LAMBDA) && (get_selected_locator().get_child_count() >= 3)
	ui_double_negative_button.visible = (get_selected_locator() != null) && (get_selected_locator().get_type() == GlobalTypes.NOT) && (get_selected_locator().get_child_count() == 1) && (get_selected_locator().get_child(0).get_type() == GlobalTypes.NOT)


func _implication_button():
	proof_step.justify_with_implication()


func _vacuous_button():
	proof_step.justify_with_vacuous()


func _reflexive_button():
	proof_step.justify_with_reflexivity()


func _matching_button():
	proof_step.justify_with_matching()


func _custom_forall_button():
	ui_custom_forall_button.get_node("NewIdentifierNameDialog").popup()


func _witness_button():
	ui_witness_button.get_node("WitnessDialog").pop_up(proof_step.get_proof_box())


func _create_lambda_button():
	var locator
	if selection_handler.get_proof_step() == proof_step:
		locator = selection_handler.get_locator()
	else:
		locator = Locator.new(requirement.get_goal())
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


func _double_negative_button():
	proof_step.justify_with_introduced_double_negative(selection_handler.get_locator())


func _on_witness_confirm():
	var ei = $Ideas/PanelContainer/VBoxContainer/WitnessButton/WitnessDialog/CenterContainer/ExprItemEdit.get_expr_item()
	proof_step.justify_with_witness(ei)


func _on_Custom_pressed():
	ui_custom_forall_button.visible = !ui_custom_forall_button.visible
	ui_custom_implication_button.visible = !ui_custom_implication_button.visible
	ui_create_lambda_button.visible = !ui_create_lambda_button.visible
	$Ideas/PanelContainer/VBoxContainer/Custom.text = "More" if $Ideas/PanelContainer/VBoxContainer/Custom.text == "Less" else "Less"
