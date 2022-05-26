extends HBoxContainer


var conditions : Array
var assumption : ExprItem
var assumption_context : ProofBox
var definitions : Array
var selected_locator : Locator
var selected_context : ProofBox

func initialise(assumption:ExprItem, assumption_context:ProofBox, _selection_handler:SelectionHandler):
	self.assumption = assumption
	self.assumption_context = assumption_context
	
	$Conclusion.set_drag_forwarding(self)
	
	var assumption_statement := Statement.new(assumption)
	
	if assumption_statement.get_conditions().size() == 0:
		$Then.hide()
	
	var conclusion:Locator = assumption_statement.get_conclusion()
	definitions = assumption_statement.get_definitions()
	
	if conclusion.get_type() != GlobalTypes.EQUALITY:
		show()
		$Conclusion.add_item(conclusion.to_string())


func get_drag_data_fw(position, node):
	return assumption.get_statement().get_conclusion()


func update_context(locator:Locator, context:ProofBox):
	selected_locator = locator
	selected_context = context
	var matching := {}
	var assumption_statement := Statement.new(assumption)
	for definition in assumption_statement.get_definitions():
		matching[definition] = "*"
	if locator.get_expr_item().compare(assumption_statement.get_conclusion().get_expr_item()):
		$Conclusion.modulate = Color.green
	elif assumption_statement.get_conclusion().get_expr_item().is_superset(locator.get_expr_item(), matching):
		$Conclusion.modulate = Color.yellow
	elif assumption_statement.get_conclusion().get_expr_item().get_type() == GlobalTypes.EXISTS and assumption_statement.get_definitions().size() == 0:
		$Conclusion.modulate = Color.cyan
	else:
		$Conclusion.modulate = Color.white


func clear_highlighting():
	$Conclusion.modulate = Color.white

func _on_item_activated(_index):
	var assumption_statement := Statement.new(assumption)
	if assumption_statement.get_conclusion().get_expr_item().get_type() == GlobalTypes.EXISTS and assumption_statement.get_definitions().size() == 0:
		var existential = assumption_statement.get_conclusion().get_expr_item()
		var existential_justification = InstantiateJustification.new(
			existential.get_child(0).get_type().to_string(),
			existential
		)
		var modus_ponens = ModusPonensJustification.new(
			assumption
		)
		selected_context.add_justification(selected_locator.get_root(), existential_justification)
		selected_context.add_justification(existential, modus_ponens)
	else:
		if assumption_statement.get_definitions().size() == 0:
			var modus_ponens = ModusPonensJustification.new(
				assumption
			)
			selected_context.add_justification(selected_locator.get_root(), modus_ponens)
		else:
			var matching = {} 
			var matches := assumption_statement.does_conclusion_match(selected_locator.get_root(), matching)
			assert(matches)
			assert(not ("*" in matching.values()))
			var refined = assumption_statement.construct_without(
				[], 
				range(assumption_statement.get_conditions().size())
			).deep_replace_types(matching)
			selected_context.add_justification(refined, RefineJustification.new(assumption))
			selected_context.add_justification(selected_locator.get_root(), ModusPonensJustification.new(refined))
