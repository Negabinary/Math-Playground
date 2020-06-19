extends PanelContainer


signal assumption_work_with
signal assumption_conclusion_used
signal assumption_condition_used
signal assumption_condition_selected
signal expr_item_dropped_on_definition
var assumption : Statement


func display_assumption(new_assumption:Statement, show_work_with := false):
	$VBoxContainer/Conditions.clear()
	$VBoxContainer/Conclusions.clear()
	
	assumption = new_assumption
	
	$VBoxContainer/Button.visible = show_work_with
	
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
	
	$VBoxContainer/Conclusions.add_item(conclusion.to_string())


func _update_conditions(conditions:Array):
	for i in conditions.size():
		var condition : UniversalLocator = conditions[i]
		$VBoxContainer/Conditions.add_item(condition.to_string())


# Show which assumptions are relevant to selection
func mark_assumptions(selected_item:UniversalLocator):
#	var matching := Matching.new(assumption.get_conclusion(), selected_item)
#	if matching.is_possible():
#		$VBoxContainer/Conclusions.modulate = Color.green
#	else:
#		$VBoxContainer/Conclusions.modulate = Color.white
	var selected_expr_item := selected_item.get_expr_item()
	var conclusion_expr_item:ExprItem = assumption.get_conclusion().get_expr_item()
	if selected_expr_item.compare(conclusion_expr_item):
		$VBoxContainer/Conclusions.modulate = Color.green
	else:
		$VBoxContainer/Conclusions.modulate = Color.white


func mark_assumptions_from_top(selected_item:UniversalLocator):
	var matching := Matching.new(selected_item, assumption.get_conclusion())
	if matching.is_possible():
		$VBoxContainer/Conclusions.modulate = Color.cyan
	else:
		$VBoxContainer/Conclusions.modulate = Color.white


func use_assumption(using_assumption:Statement):
	var selected_conditions = $VBoxContainer/Conditions.get_selected_items()
	if selected_conditions.size() == 1:
		var selected_condition:int = selected_conditions[0]
		var matching := MatchingTwo.new(assumption.get_conditions()[selected_condition], using_assumption.conclusion)
		var new_statement = assumption.deep_replace_types(matching.get_alpha_replacements(), matching.get_alpha_new_definitions())
		display_assumption(new_statement, true)


func _on_Conditions_item_selected(index):
	emit_signal("assumption_condition_selected", assumption, index)


func _on_Conditions_item_activated(index):
	emit_signal("assumption_condition_used", assumption, index)


func _on_Conclusions_item_activated(index):
	emit_signal("assumption_conclusion_used", assumption, index)


func _on_Button_pressed():
	emit_signal("assumption_work_with", assumption)


func _on_expr_item_dropped_on_definition(definition:ExprItemType, locator:UniversalLocator):
	emit_signal("expr_item_dropped_on_definition", assumption, definition, locator)
