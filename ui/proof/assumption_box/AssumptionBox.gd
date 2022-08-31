extends PanelContainer

var assumption : ExprItem
var assumption_context : SymmetryBox
var definitions := []
var selection_handler : SelectionHandler

var ui_definitions : Node
var ui_conditions : Node
var ui_conclusion : Node
var ui_actions : Node
var ui_equality : Node


# Rename to 'initialise' soon.
func initialise(assumption:ExprItem, assumption_context:SymmetryBox, selection_handler:SelectionHandler):	
	ui_definitions = $VBoxContainer/Definitions
	ui_definitions.initialise(assumption, assumption_context, selection_handler)
	ui_conditions = $VBoxContainer/Conditions
	ui_conditions.initialise(assumption, assumption_context,  selection_handler)
	ui_conclusion = $VBoxContainer/Conclusion
	ui_conclusion.initialise(assumption, assumption_context,  selection_handler)
	ui_actions = $VBoxContainer/Use
	if ui_conclusion.visible:
		$VBoxContainer/Use/InstantiateButton.init(assumption, assumption_context, selection_handler)
		$VBoxContainer/Use/UseButton.init(assumption, assumption_context, selection_handler)
		ui_actions.show()
	ui_equality = $VBoxContainer/Equality
	ui_equality.initialise(assumption, assumption_context,  selection_handler)
	
	self.selection_handler = selection_handler
	self.assumption = assumption
	self.assumption_context = assumption_context
	
	selection_handler.connect("locator_changed", self, "_update_context")


func _update_context(x):
	var locator = selection_handler.get_locator()
	var context = selection_handler.get_selected_proof_box()
	if context.get_justification_box().is_child_of(assumption_context.get_justification_box()):
		$VBoxContainer/Conclusion.update_context(locator, context)
	else:
		$VBoxContainer/Conclusion.clear_highlighting()


