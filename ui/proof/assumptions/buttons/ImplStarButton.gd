extends StarButton


var left := false


func init(assumption:ExprItem, assumption_context:SymmetryBox, selection_handler:SelectionHandler, left:=false):
	self.left = left
	.init(assumption, assumption_context, selection_handler)


func _should_display() -> bool:
	var conclusion := assumption.get_conclusion()
	return conclusion.get_type() == GlobalTypes.EQUALITY and conclusion.get_child_count() == 2


func _on_pressed():
	if pressed:
		var equality := assumption.get_conclusion()
		var x := equality.get_child(1 if left else 0).get_expr_item()
		var y := equality.get_child(0 if left else 1).get_expr_item()
		var impl = ExprItem.new(
			GlobalTypes.IMPLIES,
			[x,y]
		)
		if assumption.get_definitions().size() > 0 or assumption.get_conditions().size() > 0:
			var full_impl = equality.get_root().replace_at(
				equality.get_indeces(),
				equality.get_abandon(),
				impl
			)
			var proof_step := ProofStep.new(Requirement.new(full_impl), assumption_context)
			proof_step.justify(ImplicationJustification.new())
			var dep : ProofStep = proof_step.get_dependencies()[0]
			dep.justify(EqualityJustification.new(
				Locator.new(dep.get_goal()),
				x,
				not left
			))
			var depdep : ProofStep = proof_step.get_dependencies()[0]
			depdep.justify(ModusPonensJustification.new(
				assumption.as_expr_item()
			))
			selection_handler.assumption_pane.save_assumption(full_impl, assumption_context, self)
		else:
			var proof_step := ProofStep.new(Requirement.new(impl), assumption_context)
			proof_step.justify(ImplicationJustification.new())
			var dep : ProofStep = proof_step.get_dependencies()[0]
			dep.justify(EqualityJustification.new(
				Locator.new(dep.get_goal()),
				x,
				not left
			))
			selection_handler.assumption_pane.save_assumption(impl, assumption_context, self)
	else:
		selection_handler.assumption_pane.remove_assumption(self)
