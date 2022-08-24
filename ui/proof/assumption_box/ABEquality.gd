extends VBoxContainer


var conditions : Array
var assumption : ExprItem
var selection_handler : SelectionHandler


func initialise(assumption:ExprItem, assumption_context:SymmetryBox, selection_handler:SelectionHandler):
	self.assumption = assumption
	self.selection_handler = selection_handler
	
	var assumption_statement := Statement.new(assumption)
	var conclusion:Locator = assumption_statement.get_conclusion()
	var definitions := assumption_statement.get_definitions()
	
	if conclusion.get_type() == GlobalTypes.EQUALITY and conclusion.get_child_count() == 2:
		show()
		$LHS.add_item(assumption_context.get_parse_box().printout(conclusion.get_child(0).get_expr_item()))
		$RHS.add_item(assumption_context.get_parse_box().printout(conclusion.get_child(1).get_expr_item()))
		$UseEquality/Right.init(assumption, assumption_context, selection_handler, false)
		$UseEquality/Left.init(assumption, assumption_context, selection_handler, true)
