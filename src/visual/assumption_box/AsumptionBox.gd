extends PanelContainer


signal assumption_used
var assumption : Statement


func display_assumption(new_assumption:Statement):
	$VBoxContainer/Conditions.clear()
	$VBoxContainer/Conclusions.clear()
	
	assumption = new_assumption
	
	var definitions := new_assumption.get_definitions()
	var conditions := new_assumption.get_conditions()
	var conclusion:UniversalLocator = new_assumption.get_conclusion()
	
	if definitions.size() == 0:
		$VBoxContainer/With.hide()
		$VBoxContainer/Definitions.hide()
	else:
		$VBoxContainer/With.show()
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
	
	$VBoxContainer/Conclusions.add_item(conclusion.get_expr_item().to_string())


func _update_conditions(conditions:Array):
	for i in conditions.size():
		var condition : UniversalLocator = conditions[i]
		$VBoxContainer/Conditions.add_item(condition.get_expr_item().to_string())


# Show which assumptions are relevant to selection
func mark_assumptions(selected_item:UniversalLocator):
	# Check Conclusions
	var selected_expr_item := selected_item.get_expr_item()
	var conclusion_expr_item:ExprItem = assumption.get_conclusion().get_expr_item()
	if selected_expr_item.compare(conclusion_expr_item):
		$VBoxContainer/Conclusions.modulate = Color.green
	else:
		$VBoxContainer/Conclusions.modulate = Color.white


func _on_Conclusions_item_activated(index):
	emit_signal("assumption_used", assumption)
