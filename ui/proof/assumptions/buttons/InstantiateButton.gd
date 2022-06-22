extends Button
class_name InstantiateButton

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
	if assumption.get_conclusion().get_expr_item().get_type() == GlobalTypes.EXISTS and assumption.get_definitions().size() == 0:
		disabled = false
	else:
		visible = false


func _on_pressed():
	var existential = assumption.get_conclusion().get_expr_item()
	var existential_justification = InstantiateJustification.new(
		existential.get_child(0).get_type().to_string(),
		existential
	)
	var modus_ponens = ModusPonensJustification.new(
		assumption
	)
	selection_handler.get_selected_proof_box().add_justification(selection_handler.get_locator().get_root(), existential_justification)
	selection_handler.get_selected_proof_box().add_justification(existential, modus_ponens)
