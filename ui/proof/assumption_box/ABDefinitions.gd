extends HBoxContainer


var definitions : Array
var assumption : ProofStep
var selection_handler : SelectionHandler


func initialise(assumption:ProofStep, selection_handler:SelectionHandler):
	self.assumption = assumption
	self.selection_handler = selection_handler
	
	definitions = assumption.get_statement().get_definitions()
	
	if definitions.size() > 0:
		show()
		_update_definitions(definitions)
		$Definitions.set_drag_forwarding(self)


func _update_definitions(new_definitions:Array): # Array<ExprItemType>
	definitions = new_definitions
	for definition in definitions:
		$Definitions.add_item(definition.to_string())


func can_drop_data_fw(position, data):
	if $Definitions.get_item_at_position(position) != -1 and data is UniversalLocator:
		return data.get_statement() != assumption
	else:
		return false


func drop_data(position, data):
	var item:int = $Definitions.get_item_at_position(position)
	if item != -1 and data is UniversalLocator:
		emit_signal("expr_item_dropped_on_definition", definitions[item], data)


var last_definition

func _ons_item_activated(index):
	if index != -1:
		last_definition = definitions[index]
		$EnterExprItem.popup_centered()


func _on_ExprItem_confirmed():
	var context:ProofBox = selection_handler.get_proof_step().get_proof_box()
	var expr_item = ExprItemBuilder.from_string($EnterExprItem/VBoxContainer/LineEdit.text,context)
	var refined_ps := ProofStep.new(assumption.get_statement().deep_replace_types({last_definition:expr_item}).as_expr_item(), context)
	refined_ps.justify_with_specialisation(assumption, {last_definition:expr_item})
	get_parent().get_parent().emit_signal("proof_step_created", refined_ps)
