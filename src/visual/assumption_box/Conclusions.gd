extends ItemList

var definitions := []
var conclusion

func get_drag_data(position):
	return conclusion


func update_context(proof_step:ProofStep, locator:Locator):
	var matching := {}
	for definition in definitions:
		matching[definition] = "*"
	if locator.get_expr_item().compare(conclusion.get_expr_item()) and proof_step.needs_justification():
		modulate = Color.green
	elif conclusion.get_expr_item().is_superset(locator.get_expr_item(), matching) and proof_step.needs_justification():
		modulate = Color.yellow
	else:
		modulate = Color.white
