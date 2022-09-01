extends ActionButton
class_name EqualityButton

var left := true


func init(assumption:ExprItem, assumption_context:SymmetryBox, selection_handler:SelectionHandler, left:=false):
	self.left = left
	.init(assumption, assumption_context, selection_handler)


func _should_display() -> bool:
	return assumption.get_conclusion().get_type() == GlobalTypes.EQUALITY


func _can_use() -> bool:
	var conclusion:Locator = assumption.get_conclusion()
	var definitions := assumption.get_definitions()
	
	assert(conclusion.get_type() == GlobalTypes.EQUALITY)
	
	var equality = conclusion.get_child(int(left))
	var matching := {}
	for definition in definitions:
		matching[definition] = "*"
	if equality.get_expr_item().compare(selection_handler.get_locator().get_expr_item()):
		return true
	elif equality.get_expr_item().is_superset(selection_handler.get_locator().get_expr_item(), matching):
		return not ("*" in matching.values())
	else:
		return false


func _on_pressed() -> void:
	var selected_locator:Locator = selection_handler.get_locator()
	var selected_context:SymmetryBox = selection_handler.get_selected_proof_box()
	var selected_jbox := selected_context.get_justification_box()
	var index := 1 - int(left)
	
	var conclusion:Locator = assumption.get_conclusion()
	var definitions := assumption.get_definitions()
	
	if conclusion.get_type() == GlobalTypes.EQUALITY and conclusion.get_child_count() == 2:
		if assumption.get_definitions().size() == 0:
			var justification = EqualityJustification.new(
				selected_locator, conclusion.get_expr_item().get_child(index), index != 1
			)
			selected_jbox.set_justification(selected_locator.get_root(), justification)
		else:
			var matching := {}
			for definition in assumption.get_definitions():
				matching[definition] = "*"
			var matches := conclusion.get_child(1-index).get_expr_item().is_superset(selected_locator.get_expr_item(), matching)
			if matches and not ("*" in matching.values()):
				var refined = assumption.construct_without(
					[], 
					range(assumption.get_conditions().size())
				).deep_replace_types(matching)
				var refined_statement := Statement.new(refined)
				var just_equality := refined_statement.get_conclusion()
				# RefineJustification
				selected_jbox.set_justification(refined, RefineJustification.new(assumption.as_expr_item()))
				if refined_statement.conditions.size() != 0:
					# ModusPonensJustification
					selected_jbox.set_justification(just_equality.get_expr_item(), ModusPonensJustification.new(refined))
				# EqualityJustification
				var justification = EqualityJustification.new(
					selected_locator, just_equality.get_expr_item().get_child(index), index != 1
				)
				selected_jbox.set_justification(selected_locator.get_root(), justification)
