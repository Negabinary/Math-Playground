extends ItemList

var conclusion

func get_drag_data(position):
	return conclusion


func update_context(proof_step:ProofStep, locator:Locator):
	if locator.get_expr_item().compare(conclusion.get_expr_item()) and proof_step.needs_justification():
		modulate = Color.green
	else:
		modulate = Color.white
