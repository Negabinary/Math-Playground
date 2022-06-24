extends Button
class_name EqualityButton

var assumption : Statement
var assumption_context : ProofBox
var selection_handler : SelectionHandler
var left := true

func _init():
	add_stylebox_override("normal", get_stylebox("green", "Button"))
	add_stylebox_override("pressed", get_stylebox("green_pressed", "Button"))
	add_stylebox_override("hover", get_stylebox("green_hover", "Button"))


func init(assumption:ExprItem, assumption_context:ProofBox, selection_handler:SelectionHandler, left:=false):
	self.assumption = Statement.new(assumption)
	self.assumption_context = assumption_context
	self.selection_handler = selection_handler
	self.left = left
	disabled = true
	selection_handler.connect("locator_changed", self, "_update_context")
	connect("pressed", self, "_on_pressed")


func _update_context(x):
	var conclusion:Locator = assumption.get_conclusion()
	var definitions := assumption.get_definitions()
	
	assert(conclusion.get_type() == GlobalTypes.EQUALITY)
	
	var equality = conclusion.get_child(int(left))
	var matching := {}
	for definition in definitions:
		matching[definition] = "*"
	if equality.get_expr_item().compare(selection_handler.get_locator().get_expr_item()):
		disabled = false
	elif equality.get_expr_item().is_superset(selection_handler.get_locator().get_expr_item(), matching):
		disabled = false
	else:
		disabled = true


func _on_pressed():
	var selected_locator:Locator = selection_handler.get_locator()
	var selected_context:ProofBox = selection_handler.get_selected_proof_box()
	var index := 1 - int(left)
	
	var conclusion:Locator = assumption.get_conclusion()
	var definitions := assumption.get_definitions()
	
	if conclusion.get_type() == GlobalTypes.EQUALITY and conclusion.get_child_count() == 2:
		if assumption.get_definitions().size() == 0:
			var justification = EqualityJustification.new(
				selected_locator, conclusion.get_expr_item().get_child(index), index != 1
			)
			selected_context.add_justification(selected_locator.get_root(), justification)
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
				selected_context.add_justification(refined, RefineJustification.new(assumption.as_expr_item()))
				if refined_statement.conditions.size() != 0:
					# ModusPonensJustification
					selected_context.add_justification(just_equality.get_expr_item(), ModusPonensJustification.new(refined))
				# EqualityJustification
				var justification = EqualityJustification.new(
					selected_locator, just_equality.get_expr_item().get_child(index), index != 1
				)
				selected_context.add_justification(selected_locator.get_root(), justification)
