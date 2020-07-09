extends PanelContainer

signal use_equality
signal assumption_conclusion_used
signal assumption_condition_used
signal assumption_condition_selected
signal expr_item_dropped_on_definition

var assumption : ProofStep


func display_assumption(new_assumption:ProofStep):
	$VBoxContainer/Conditions.clear()
	$VBoxContainer/Conclusion.clear()
	
	assumption = new_assumption
	
	var assumption_statement := assumption.get_statement()
	
	var definitions := assumption_statement.get_definitions()
	var conditions := assumption_statement.get_conditions()
	var conclusion:Locator = assumption_statement.get_conclusion()
	
	if definitions.size() == 0:
		$VBoxContainer/With.hide()
		$VBoxContainer/Definitions.hide()
	else:
		$VBoxContainer/With.show()
		$VBoxContainer/Definitions.assumption = new_assumption
		$VBoxContainer/Definitions.show()
		$VBoxContainer/Definitions.update_definitions(definitions)
	
	if conditions.size() == 0:
		$VBoxContainer/If.hide()
		$VBoxContainer/Conditions.hide()
		$VBoxContainer/Then.text = "WE KNOW"
	else:
		$VBoxContainer/If.show()
		$VBoxContainer/Conditions.show()
		$VBoxContainer/Then.text = "THEN"
		_update_conditions(conditions)
	
	if conclusion.get_type() == GlobalTypes.EQUALITY:
		$VBoxContainer/Equals.show()
		$VBoxContainer/Equalities.show()
		$VBoxContainer/Conclusion.hide()
		$VBoxContainer/Equalities.add_equalities(assumption, UniversalLocator.new(assumption_statement, conclusion))
	else:
		$VBoxContainer/Equals.hide()
		$VBoxContainer/Equalities.hide()
		$VBoxContainer/Conclusion.show()
		$VBoxContainer/Conclusion.add_item(conclusion.to_string())
		$VBoxContainer/Conclusion.conclusion = UniversalLocator.new(assumption_statement, conclusion)


func _update_conditions(conditions:Array):
	for i in conditions.size():
		var condition : UniversalLocator = UniversalLocator.new(assumption.get_statement(), conditions[i])
		$VBoxContainer/Conditions.add_item(condition.to_string())


func update_context(proof_step:ProofStep, locator:Locator):
	if assumption.get_conclusion().get_type() == GlobalTypes.EQUALITY:
		$VBoxContainer/Equalities.update_context(proof_step, locator)
	else:
		$VBoxContainer/Conclusion.update_context(proof_step, locator)


func _on_Conditions_item_selected(index):
	emit_signal("assumption_condition_selected", assumption, index)


func _on_Conditions_item_activated(index):
	emit_signal("assumption_condition_used", assumption, index)


func _on_expr_item_dropped_on_definition(definition:ExprItemType, locator:UniversalLocator):
	emit_signal("expr_item_dropped_on_definition", assumption, definition, locator)


func _on_use_equality(equality:UniversalLocator):
	emit_signal("use_equality", assumption, equality)


func _on_Conclusion_item_activated(index):
	emit_signal("assumption_conclusion_used", assumption, index)
