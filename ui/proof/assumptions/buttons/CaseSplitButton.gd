extends ActionButton
class_name CaseSplitButton


func _should_display() -> bool:
	return assumption.get_conclusion().get_type() == GlobalTypes.OR and assumption.get_definitions().size() == 0


func _can_use() -> bool:
	return true


func _on_pressed():
	var disjunction = assumption.get_conclusion().get_expr_item()
	var disjunction_justification = CaseSplitJustification.new(
		disjunction
	)
	selection_handler.get_selected_proof_box().get_justification_box().set_justification(selection_handler.get_locator().get_root(), disjunction_justification)
	if assumption.get_conditions().size() > 0:
		var modus_ponens = ModusPonensJustification.new(
			assumption.as_expr_item()
		)
		selection_handler.get_selected_proof_box().get_justification_box().set_justification(disjunction, modus_ponens)
