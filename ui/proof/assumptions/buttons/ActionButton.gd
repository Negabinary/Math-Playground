extends Button
class_name ActionButton


var assumption : Statement
var assumption_context : ProofBox
var selection_handler : SelectionHandler


func _init():
	add_stylebox_override("normal", get_stylebox("green", "Button"))
	add_stylebox_override("pressed", get_stylebox("green_pressed", "Button"))
	add_stylebox_override("hover", get_stylebox("green_hover", "Button"))


# VIRTUAL METHODS =========================================


func _should_display() -> bool:
	assert(false)
	return false


func _can_use() -> bool:
	return false


func _on_pressed() -> void:
	assert(false)


# OTHER METHODS ===========================================


func init(assumption:ExprItem, assumption_context:ProofBox, selection_handler:SelectionHandler):
	self.assumption = Statement.new(assumption)
	self.assumption_context = assumption_context
	self.selection_handler = selection_handler
	if _should_display():
		disabled = true
		selection_handler.connect("locator_changed", self, "_update_context")
		connect("pressed", self, "_on_pressed")
	else:
		hide()


func _is_in_context() -> bool:
	return assumption_context.is_ancestor_of(selection_handler.get_selected_proof_box())


func _update_context(_x):
	var context = selection_handler.get_selected_proof_box()
	if _is_in_context():
		disabled = not _can_use()
	else:
		disabled = true
