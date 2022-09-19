extends StarButton


var right := false


func init(assumption:ExprItem, assumption_context:SymmetryBox, selection_handler:SelectionHandler, right:=false):
	self.right = right
	.init(assumption, assumption_context, selection_handler)


func _should_display() -> bool:
	var conclusion := assumption.get_conclusion()
	return conclusion.get_type() == GlobalTypes.AND and conclusion.get_child_count() == 2


func _on_pressed():
	if pressed:
		var conjunction := assumption.get_conclusion()
		var half := conjunction.get_child(1 if right else 0).get_expr_item()
		if assumption.get_definitions().size() > 0 or assumption.get_conditions().size() > 0:
			var full_half = conjunction.get_root().replace_at(
				conjunction.get_indeces(),
				conjunction.get_abandon(),
				half
			)
			var proof_step = ProofStep.new(
				Requirement.new(full_half),
				assumption_context
			)
			proof_step.justify(ImplicationJustification.new())
			var dep : ProofStep = proof_step.get_dependencies()[0]
			dep.justify(FromConjunctionJustification.new(conjunction.get_expr_item()))
			selection_handler.assumption_pane.save_assumption(full_half, assumption_context, self)
		else:
			assumption_context.justification_box.set_justification(
				half, 
				FromConjunctionJustification.new(conjunction.get_expr_item())
			)
			selection_handler.assumption_pane.save_assumption(half, assumption_context, self)
	else:
		selection_handler.assumption_pane.remove_assumption(self)
