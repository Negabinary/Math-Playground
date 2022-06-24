extends Button
class_name UseButton

var assumption : Statement
var assumption_context : ProofBox
var selection_handler : SelectionHandler

func _init():
	add_stylebox_override("normal", get_stylebox("green", "Button"))
	add_stylebox_override("pressed", get_stylebox("green_pressed", "Button"))
	add_stylebox_override("hover", get_stylebox("green_hover", "Button"))


func init(assumption:ExprItem, assumption_context:ProofBox, selection_handler:SelectionHandler):
	self.assumption = Statement.new(assumption)
	self.assumption_context = assumption_context
	self.selection_handler = selection_handler
	disabled = true
	selection_handler.connect("locator_changed", self, "_update_context")
	connect("pressed", self, "_on_pressed")


func _update_context(x):
	var context = selection_handler.get_selected_proof_box()
	var expr_item = selection_handler.get_locator().get_root()
	var matching := {}
	for definition in assumption.get_definitions():
		matching[definition] = "*"
	if expr_item.compare(assumption.get_conclusion().get_expr_item()):
		disabled = false
	elif assumption.get_conclusion().get_expr_item().is_superset(expr_item, matching) and not "*" in matching.values():
		disabled = false
	else:
		disabled = true


func _on_pressed():
	if assumption.get_definitions().size() == 0:
		var modus_ponens = ModusPonensJustification.new(
			assumption
		)
		selection_handler.get_selected_proof_box().add_justification(selection_handler.get_locator().get_root(), modus_ponens)
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
		selection_handler.get_selected_proof_box().add_justification(refined, RefineJustification.new(assumption.as_expr_item()))
		selection_handler.get_selected_proof_box().add_justification(selection_handler.get_locator().get_root(), ModusPonensJustification.new(refined))
