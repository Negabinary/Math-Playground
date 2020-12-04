extends HBoxContainer


var conditions : Array
var assumption : ProofStep
var definitions : Array
var selection_handler : SelectionHandler


func initialise(assumption:ProofStep, selection_handler:SelectionHandler):
	self.assumption = assumption
	self.selection_handler = selection_handler
	
	$Conclusion.set_drag_forwarding(self)
	
	if assumption.get_statement().get_conditions().size() == 0:
		$Then.hide()
	
	var assumption_statement := assumption.get_statement()
	var conclusion:Locator = assumption_statement.get_conclusion()
	definitions = assumption_statement.get_definitions()
	
	if conclusion.get_type() != GlobalTypes.EQUALITY:
		show()
		$Conclusion.add_item(conclusion.to_string())


func get_drag_data_fw(position, node):
	return assumption.get_statement().get_conclusion()


func update_context(proof_step:ProofStep, locator:Locator):
	var matching := {}
	for definition in assumption.get_statement().get_definitions():
		matching[definition] = "*"
	if locator.get_expr_item().compare(assumption.get_statement().get_conclusion().get_expr_item()) and proof_step.needs_justification():
		$Conclusion.modulate = Color.green
	elif assumption.get_statement().get_conclusion().get_expr_item().is_superset(locator.get_expr_item(), matching) and proof_step.needs_justification():
		$Conclusion.modulate = Color.yellow
	else:
		$Conclusion.modulate = Color.white


func clear_highlighting():
	$Conclusion.modulate = Color.white


