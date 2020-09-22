extends ItemList

signal use_equality

var definitions := []
var equalities := []

func add_equalities(locator:UniversalLocator):
	equalities = [locator.get_child(0), locator.get_child(1)]
	for equality in equalities:
		add_item(equality.to_string())


func update_context(proof_step:ProofStep, locator:Locator):
	var valid = false
	var valid_with_sub = false
	for i in equalities.size():
		var equality = equalities[i]
		var matching := {}
		for definition in definitions:
			matching[definition] = "*"
		if equality.get_expr_item().compare(locator.get_expr_item()):
			if proof_step.needs_justification():
				set_item_custom_bg_color(1-i, Color8(142,166,4,100))
				update()
			else:
				set_item_custom_bg_color(1-i, Color8(142,166,4,0))
				update()
		elif equality.get_expr_item().is_superset(locator.get_expr_item(), matching) and proof_step.needs_justification():
			if proof_step.needs_justification():
				set_item_custom_bg_color(1-i, Color8(142,166,4,50))
				update()
			else:
				set_item_custom_bg_color(1-i, Color8(142,166,4,0))
				update()
		else:
			set_item_custom_bg_color(1-i, Color8(142,166,4,0))
			update()


func _on_item_activated(index):
	emit_signal("use_equality", index)
