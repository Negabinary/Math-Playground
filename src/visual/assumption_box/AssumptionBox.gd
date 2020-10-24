extends PanelContainer

signal use_equality
signal assumption_conclusion_used # (self, index)
signal proof_step_created # (ProofStep)
signal request_to_prove # ()

var assumption : ProofStep
var definitions := []
var selection_handler : SelectionHandler


func _ready():
	$PopupMenu.connect("prove", self, "emit_signal",["request_to_prove"])


func display_assumption(new_assumption:ProofStep, selection_handler:SelectionHandler):
	$VBoxContainer/Conditions/Conditions.clear()
	$VBoxContainer/Conclusion/Conclusion.clear()
	
	assumption = new_assumption
	self.selection_handler = selection_handler
	
	if assumption.is_tag():
		modulate = Color.coral
	else:
		modulate = Color.white
	
	var assumption_statement := assumption.get_statement()
	
	definitions = assumption_statement.get_definitions()
	var conditions := assumption_statement.get_conditions()
	var conclusion:Locator = assumption_statement.get_conclusion()
	
	if definitions.size() == 0:
		$VBoxContainer/Definitions.hide()
	else:
		$VBoxContainer/Definitions.show()
		$VBoxContainer/Definitions/Definitions.assumption = new_assumption
		$VBoxContainer/Definitions/Definitions.update_definitions(definitions)
	
	if conditions.size() == 0:
		$VBoxContainer/Conditions.hide()
		$VBoxContainer/Conclusion/Then.hide()
	else:
		$VBoxContainer/Conditions.show()
		$VBoxContainer/Conclusion/Then.show()
		_update_conditions(conditions)
	
	if conclusion.get_type() == GlobalTypes.EQUALITY:
		$VBoxContainer/Equality.show()
		$VBoxContainer/Conclusion.hide()
		$VBoxContainer/Equality/Equalities.add_equalities(UniversalLocator.new(assumption_statement, conclusion))
		$VBoxContainer/Equality/Equalities.definitions = definitions
	else:
		$VBoxContainer/Equality.hide()
		$VBoxContainer/Conclusion.show()
		$VBoxContainer/Conclusion/Conclusion.add_item(conclusion.to_string())
		$VBoxContainer/Conclusion/Conclusion.conclusion = UniversalLocator.new(assumption_statement, conclusion)
		$VBoxContainer/Conclusion/Conclusion.definitions = definitions


func _update_conditions(conditions:Array):
	for i in conditions.size():
		var condition : UniversalLocator = UniversalLocator.new(assumption.get_statement(), conditions[i])
		$VBoxContainer/Conditions/Conditions.add_item(condition.to_string())


func update_context(proof_step:ProofStep, locator:Locator):
	if assumption.get_conclusion().get_type() == GlobalTypes.EQUALITY:
		$VBoxContainer/Equality/Equalities.update_context(proof_step, locator)
	else:
		$VBoxContainer/Conclusion/Conclusion.update_context(proof_step, locator)


func _on_expr_item_dropped_on_definition(definition:ExprItemType, locator:UniversalLocator):
	var refined_ps := ProofStep.new(assumption.get_statement().deep_replace_types({definition:locator.get_expr_item()}).as_expr_item())
	refined_ps.justify_with_specialisation(assumption, {definition:locator.get_expr_item()})
	emit_signal("proof_step_created", refined_ps)


func _on_use_equality(index:int):
	emit_signal("use_equality", assumption, index)


func _on_Conclusion_item_activated(index):
	emit_signal("assumption_conclusion_used", assumption, index)


func _on_AssumptionBox_gui_input(event:InputEvent):
	if event.is_action_released("right_click"):
		$PopupMenu.popup(Rect2(rect_global_position + event.position, Vector2(1,1)))


var last_definition

func _on_Definitions_item_activated(index):
	if index != -1:
		last_definition = definitions[index]
		$EnterExprItem.popup_centered()


func _on_EnterExprItem_confirmed():
	var context := selection_handler.get_module().get_scope_stack()
	var expr_item = ExprItemBuilder.from_string($EnterExprItem/VBoxContainer/LineEdit.text,context)
	var refined_ps := ProofStep.new(assumption.get_statement().deep_replace_types({last_definition:expr_item}).as_expr_item())
	refined_ps.justify_with_specialisation(assumption, {last_definition:expr_item})
	emit_signal("proof_step_created", refined_ps)
