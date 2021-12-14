extends PanelContainer

signal use_equality
signal assumption_conclusion_used # (self, index)
signal proof_step_created # (ProofStep)
signal request_to_prove # ()

var assumption : ProofStep
var definitions := []
var selection_handler : SelectionHandler

var ui_definitions : Node
var ui_conditions : Node
var ui_conclusion : Node
var ui_equality : Node


# Rename to 'initialise' soon.
func display_assumption(assumption:ProofStep, selection_handler:SelectionHandler):	
	ui_definitions = $VBoxContainer/Definitions
	ui_definitions.initialise(assumption, selection_handler)
	ui_conditions = $VBoxContainer/Conditions
	ui_conditions.initialise(assumption, selection_handler)
	ui_conclusion = $VBoxContainer/Conclusion
	ui_conclusion.initialise(assumption, selection_handler)
	ui_equality = $VBoxContainer/Equality
	ui_equality.initialise(assumption, selection_handler)
	
	self.selection_handler = selection_handler
	self.assumption = assumption
	
	if assumption.is_tag():
		modulate = Color.coral
	else:
		modulate = Color.white


func update_context(proof_step:ProofStep, locator:Locator):
	if not proof_step.is_proven():
		if locator == null:
			$VBoxContainer/Conclusion.update_context(proof_step, 
				Locator.new(proof_step.get_statement().as_expr_item())
			)
			$VBoxContainer/Equality/Equalities.clear_highlighting()
		elif locator.get_expr_item().compare(proof_step.get_statement().as_expr_item()):
			$VBoxContainer/Conclusion.update_context(proof_step, locator)
			$VBoxContainer/Equality/Equalities.update_context(proof_step, locator)
		else:
			$VBoxContainer/Conclusion.clear_highlighting()
			$VBoxContainer/Equality/Equalities.update_context(proof_step, locator)
	else:
		$VBoxContainer/Conclusion.clear_highlighting()
		$VBoxContainer/Equality/Equalities.clear_highlighting()


func _on_expr_item_dropped_on_definition(definition:ExprItemType, locator:UniversalLocator):
	var refined_ps := ProofStep.new(assumption.get_expr_item().deep_replace_types({definition:locator.get_expr_item()}))
	refined_ps.justify_with_specialisation(assumption, {definition:locator.get_expr_item()})
	emit_signal("proof_step_created", refined_ps)


func _on_use_equality(index:int):
	emit_signal("use_equality", assumption, index)


func _on_Conclusion_item_activated(index):
	emit_signal("assumption_conclusion_used", assumption, index)

