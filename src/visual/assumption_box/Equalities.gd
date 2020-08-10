extends ItemList

signal use_equality

var definitions := []
var equalities := []

func add_equalities(locator:UniversalLocator):
	var queue := [locator]
	while queue.size() != 0:
		var next = queue.pop_front()
		if next.get_type() == GlobalTypes.EQUALITY:
			queue.push_front(next.get_child(0))
			queue.push_front(next.get_child(1))
		else:
			equalities.append(next)
	
	for equality in equalities:
		add_item(equality.to_string())


func update_context(proof_step:ProofStep, locator:Locator):
	var valid = false
	for equality in equalities:
		if equality.get_expr_item().compare(locator.get_expr_item()):
			valid = true
			break
	if valid and proof_step.needs_justification():
		modulate = Color.greenyellow
	else:
		modulate = Color.white


func _on_item_activated(index):
	var equality = equalities[index]
	emit_signal("use_equality", equality)
