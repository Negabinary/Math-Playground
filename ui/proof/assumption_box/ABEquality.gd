extends HBoxContainer


var conditions : Array
var assumption : ExprItem
var selection_handler : SelectionHandler
var selected_locator : Locator
var selected_context : ProofBox


func initialise(assumption:ExprItem, assumption_context:ProofBox, selection_handler:SelectionHandler):
	self.assumption = assumption
	self.selection_handler = selection_handler
	
	var assumption_statement := Statement.new(assumption)
	var conclusion:Locator = assumption_statement.get_conclusion()
	var definitions := assumption_statement.get_definitions()
	
	if conclusion.get_type() == GlobalTypes.EQUALITY and conclusion.get_child_count() == 2:
		show()
		for side in [conclusion.get_child(0), conclusion.get_child(1)]:
			$Equalities.add_item(side.to_string())


func update_context(selected_locator:Locator, selected_context:ProofBox):
	self.selected_locator = selected_locator
	self.selected_context = selected_context
	
	var assumption_statement := Statement.new(assumption)
	var conclusion:Locator = assumption_statement.get_conclusion()
	var definitions := assumption_statement.get_definitions()
	
	if conclusion.get_type() == GlobalTypes.EQUALITY:
		for i in 2:
			var equality = conclusion.get_child(i)
			var matching := {}
			for definition in definitions:
				matching[definition] = "*"
			if equality.get_expr_item().compare(selected_locator.get_expr_item()):
				$Equalities.set_item_custom_bg_color(1-i, Color8(142,166,4,100))
				update()
			elif equality.get_expr_item().is_superset(selected_locator.get_expr_item(), matching):
				$Equalities.set_item_custom_bg_color(1-i, Color8(142,166,4,50))
				update()
			else:
				$Equalities.set_item_custom_bg_color(1-i, Color8(142,166,4,0))
				update()


func clear_highlighting():
	for i in 2:
		$Equalities.set_item_custom_bg_color(i, Color8(142,166,4,0))
		update()


func _on_item_activated(index):
	var assumption_statement := Statement.new(assumption)
	var conclusion:Locator = assumption_statement.get_conclusion()
	var definitions := assumption_statement.get_definitions()
	
	if conclusion.get_type() == GlobalTypes.EQUALITY and conclusion.get_child_count() == 2:
		if assumption_statement.get_definitions().size() == 0:
			var justification = EqualityJustification.new(
				selected_locator, conclusion.get_expr_item().get_child(index), index != 1
			)
			selected_context.add_justification(selected_locator.get_root(), justification)
		else:
			var matching := {}
			for definition in assumption_statement.get_definitions():
				matching[definition] = "*"
			var matches := conclusion.get_child(1-index).get_expr_item().is_superset(selected_locator.get_expr_item(), matching)
			if matches and not ("*" in matching.values()):
				var refined = assumption_statement.construct_without(
					[], 
					range(assumption_statement.get_conditions().size())
				).deep_replace_types(matching)
				var refined_statement := Statement.new(refined)
				var just_equality := refined_statement.get_conclusion()
				# RefineJustification
				selected_context.add_justification(refined, RefineJustification.new(assumption))
				if refined_statement.conditions.size() != 0:
					# ModusPonensJustification
					selected_context.add_justification(just_equality.get_expr_item(), ModusPonensJustification.new(refined))
				# EqualityJustification
				var justification = EqualityJustification.new(
					selected_locator, just_equality.get_expr_item().get_child(index), index != 1
				)
				selected_context.add_justification(selected_locator.get_root(), justification)

