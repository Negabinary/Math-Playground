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
	
	if assumption.get_conclusion().get_expr_item().is_superset(expr_item, matching):
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
		var remaining_types = []
		for i in matching:
			if matching[i] is String:
				var temp_type := ExprItemType.new(i.get_identifier())
				remaining_types.append(temp_type)
				matching[i] = ExprItem.new(temp_type)
		var refined = assumption.construct_without(
			[], 
			range(assumption.get_conditions().size())
		).deep_replace_types(matching)
		var provable = Provable.new(
			selection_handler.get_selected_goal()
		)
		provable.justify(ModusPonensJustification.new(refined))
		provable.get_child(provable.get_child_count()-1).justify(
			RefineJustification.new(assumption.as_expr_item())
		)
		if remaining_types.empty():
			provable.apply_proof(selection_handler.get_selected_proof_box())
		else:
			var refinable := Refinable.new(
				provable,
				remaining_types
			)
			$"%RefineDialog".request_types(refinable, selection_handler.get_selected_proof_box())
