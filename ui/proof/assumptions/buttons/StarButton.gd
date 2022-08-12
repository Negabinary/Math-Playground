extends Button
class_name StarButton


var assumption : Statement
var assumption_context : SymmetryBox


func _init():
	add_stylebox_override("normal", get_stylebox("star", "Button"))
	add_stylebox_override("pressed", get_stylebox("star_pressed", "Button"))
	add_stylebox_override("hover", get_stylebox("star_hover", "Button"))
	toggle_mode = true


func init(assumption:ExprItem, assumption_context:SymmetryBox, selection_handler:SelectionHandler):
	self.assumption = Statement.new(assumption)
	self.assumption_context = assumption_context
	if _should_display():
		disabled = false
		connect("pressed", self, "_on_pressed")
	else:
		hide()


func _should_display() -> bool:
	var conclusion := assumption.get_conclusion()
	if conclusion.get_type() in [GlobalTypes.EXISTS, GlobalTypes.EQUALITY]:
		return true
	if assumption.get_definitions().size() > 0:
		return true
	if assumption.get_conditions().size() > 0:
		return true
	return false



