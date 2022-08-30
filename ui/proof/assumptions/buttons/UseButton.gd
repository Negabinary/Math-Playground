extends ActionButton
class_name UseButton


func _should_display() -> bool:
	return not (assumption.get_definitions().size() == 0 and assumption.get_conditions().size() == 0)


func _can_use() -> bool:
	var expr_item = selection_handler.get_locator().get_root()
	if expr_item.compare(assumption.get_conclusion().get_expr_item()):
		return true
	
	var matching := {}
	for definition in assumption.get_definitions():
		matching[definition] = "*"
	
	if assumption.get_conclusion().get_expr_item().is_superset(expr_item, matching) and not "*" in matching.values():
		return true
	else:
		return false


func _on_pressed() -> void:
	if assumption.get_definitions().size() == 0:
		var modus_ponens = ModusPonensJustification.new(
			assumption.as_expr_item()
		)
		selection_handler.get_selected_proof_box().get_justification_box().set_justification(selection_handler.get_locator().get_root(), modus_ponens)
	else:
		var matching = {} 
		for definition in assumption.get_definitions():
			matching[definition] = "*"
		var matches := assumption.does_conclusion_match(selection_handler.get_locator().get_root(), matching)
		assert(matches)
		assert(not ("*" in matching.values()))
		var refined = assumption.construct_without(
			[], 
			range(assumption.get_conditions().size())
		).deep_replace_types(matching)
		selection_handler.get_selected_proof_box().get_justification_box().set_justification(refined, RefineJustification.new(assumption.as_expr_item()))
		selection_handler.get_selected_proof_box().get_justification_box().set_justification(selection_handler.get_locator().get_root(), ModusPonensJustification.new(refined))
