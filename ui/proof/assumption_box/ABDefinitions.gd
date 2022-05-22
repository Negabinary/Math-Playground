extends HBoxContainer


var definitions : Array
var assumption : ExprItem
var selection_handler : SelectionHandler


func initialise(assumption:ExprItem, assumption_context:ProofBox, _selection_handler:SelectionHandler):
	self.assumption = assumption
	self.selection_handler = selection_handler
	
	definitions = Statement.new(assumption).get_definitions()
	
	if definitions.size() > 0:
		show()
		_update_definitions(definitions)
		$Definitions.set_drag_forwarding(self)


func _update_definitions(new_definitions:Array): # Array<ExprItemType>
	definitions = new_definitions
	for definition in definitions:
		$Definitions.add_item(definition.to_string())


var last_definition

func _ons_item_activated(index):
	if index != -1:
		last_definition = definitions[index]
		$EnterExprItem.popup_centered()


func _on_ExprItem_confirmed():
	var context:ProofBox = selection_handler.get_selected_goal().get_proof_box()
	var expr_item = ExprItemBuilder.from_string($EnterExprItem/VBoxContainer/LineEdit.text,context)
	var specialization = RefineJustification.new(assumption)
	selection_handler.get_selected_proof_box().add_justification(expr_item, specialization)
	get_parent().get_parent().emit_signal("proof_step_created", expr_item)
