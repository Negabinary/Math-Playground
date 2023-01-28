extends ActionButton
class_name InstantiateButton


func _should_display() -> bool:
	return assumption.get_conclusion().get_type() == GlobalTypes.EXISTS


func _can_use() -> bool:
	return true


func _on_pressed():
	var remaining_types := []
	var matching := {}
	for i in assumption.get_definitions():
		var temp_type := ExprItemType.new(i.get_identifier())
		remaining_types.append(temp_type)
		matching[i] = ExprItem.new(temp_type)
	var refined = assumption.construct_without(
		[], 
		range(assumption.get_conditions().size())
	).deep_replace_types(matching)
	
	var provable := Provable.new(selection_handler.get_selected_goal())
	var existential := Statement.new(refined).get_conclusion().get_expr_item()
	provable.justify(InstantiateJustification.new(
		existential.get_child(0).get_type().to_string(),
		existential
	))
	var inner_provable := provable
	if assumption.get_conditions().size() > 0:
		inner_provable = provable.get_child(0)
		inner_provable.justify(ModusPonensJustification.new(
			refined
		))
	if assumption.get_definitions().size() == 0:
		provable.apply_proof(selection_handler.get_selected_proof_box())
	else:
		inner_provable.get_child(inner_provable.get_child_count()-1).justify(
			RefineJustification.new((
				assumption.as_expr_item()
			)
		))
		var refinable := Refinable.new(
			provable,
			remaining_types
		)
		$"%RefineDialog".request_types(refinable, selection_handler.get_selected_proof_box())
