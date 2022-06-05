extends HBoxContainer


var definitions : Array
var assumption : ExprItem
var selection_handler : SelectionHandler
var last_definition
var parser : ExprItemParser2


func initialise(assumption:ExprItem, assumption_context:ProofBox, _selection_handler:SelectionHandler):
	self.assumption = assumption
	self.selection_handler = _selection_handler
	
	definitions = Statement.new(assumption).get_definitions()
	
	if definitions.size() > 0:
		show()
		_update_definitions(definitions)


	$ConfirmationDialog/VBoxContainer/TextEdit.connect("text_changed", self, "_validate")
	_validate()


func _update_definitions(new_definitions:Array): # Array<ExprItemType>
	definitions = new_definitions
	for definition in definitions:
		$Definitions.add_item(definition.to_string())


func _ons_item_activated(index):
	if index != -1:
		last_definition = definitions[index]
		$ConfirmationDialog.popup_centered()


func _validate():
	var string_to_parse = $ConfirmationDialog/VBoxContainer/TextEdit.text
	var selected_context = selection_handler.get_selected_proof_box()
	parser = ExprItemParser2.new(string_to_parse, selected_context.get_parse_box())
	if parser.error:
		$ConfirmationDialog.get_ok().disabled = true
		$ConfirmationDialog/VBoxContainer/Label.text = str(parser.error_dict)
	else:
		$ConfirmationDialog.get_ok().disabled = false
		$ConfirmationDialog.get_ok().connect("pressed", self, "ok")
		$ConfirmationDialog/VBoxContainer/Label.text = ""


func ok():
	var expr_item = parser.result
	var specialization = RefineJustification.new(assumption)
	var statement = Statement.new(assumption)
	var remaining_definitions = range(len(statement.get_definitions()))
	remaining_definitions.erase(statement.get_definitions().find(last_definition))
	var remaining_conditions = range(len(statement.get_conditions()))
	var specialized = statement.construct_without(remaining_definitions, remaining_conditions).deep_replace_types({last_definition:expr_item})
	selection_handler.get_selected_proof_box().add_justification(specialized, specialization)
	get_parent().get_parent().emit_signal("proof_step_created", 0)
