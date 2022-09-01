extends HBoxContainer


var definitions : Array
var assumption : ExprItem
var assumption_context : SymmetryBox
var selection_handler : SelectionHandler
var last_definition
var parser : ExprItemParser2
var parse_context


func initialise(assumption:ExprItem, assumption_context:SymmetryBox, _selection_handler:SelectionHandler):
	self.assumption = assumption
	self.assumption_context = assumption_context
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
	var selected_context:SymmetryBox = selection_handler.get_selected_proof_box()
	if selected_context and selected_context.get_parse_box().is_inside(assumption_context.get_parse_box()):
		parse_context = selected_context
	else:
		parse_context = assumption_context
	parser = ExprItemParser2.new(string_to_parse, parse_context.get_parse_box())
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
	parse_context.get_justification_box().set_justification(specialized, specialization)
	selection_handler.assumption_pane.save_assumption(specialized, parse_context)
