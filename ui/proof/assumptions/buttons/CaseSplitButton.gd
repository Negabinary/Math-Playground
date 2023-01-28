extends ActionButton
class_name CaseSplitButton


func _should_display() -> bool:
	return assumption.get_conclusion().get_type() == GlobalTypes.OR


func _can_use() -> bool:
	return true


func _on_pressed():
	var remaining_types := []
	var matching := {}
	for i in assumption.get_definitions():
		var temp_type := ExprItemType.new(i.get_identifier())
		remaining_types.append(temp_type)
		matching[i] = ExprItem.new(temp_type)
	
	var bottom_provable = Provable.new(selection_handler.get_selected_goal())
	var top_provable = bottom_provable
	
	# Case Split
	var disjunction = assumption.get_conclusion().get_expr_item().deep_replace_types(matching)
	top_provable.justify(CaseSplitJustification.new(disjunction))
	top_provable = top_provable.get_child(top_provable.get_child_count() - 1)
	
	# Modus Ponens
	if assumption.get_conditions().size() > 0:
		var cd = assumption.construct_without([], range(matching.size())).deep_replace_types(matching)
		top_provable.justify(ModusPonensJustification.new(cd))
		top_provable = top_provable.get_child(top_provable.get_child_count() - 1)
	
	# Refine
	if matching.size() > 0:
		top_provable.justify(RefineJustification.new(assumption.as_expr_item()))
		var refinable := Refinable.new(bottom_provable, remaining_types)
		$"%RefineDialog".request_types(refinable, selection_handler.get_selected_proof_box())
	else:
		bottom_provable.apply_proof(
			selection_handler.get_selected_proof_box()
		)
