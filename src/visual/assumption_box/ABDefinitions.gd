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
