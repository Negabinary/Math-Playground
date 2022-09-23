extends VBoxContainer


var conditions : Array
var assumption : ExprItem
var selection_handler : SelectionHandler

var lhs_autostring : Autostring
var rhs_autostring : Autostring

func initialise(assumption:ExprItem, assumption_context:SymmetryBox, selection_handler:SelectionHandler):
	self.assumption = assumption
	self.selection_handler = selection_handler
	
	var assumption_statement := Statement.new(assumption)
	var conclusion:Locator = assumption_statement.get_conclusion()
	var definitions := assumption_statement.get_definitions()
	
	if conclusion.get_type() == GlobalTypes.EQUALITY and conclusion.get_child_count() == 2:
		show()
		lhs_autostring = ExprItemAutostring.new(
			conclusion.get_child(0).get_expr_item(), 
			assumption_statement.get_inner_parse_box(assumption_context.get_parse_box())
		)
		_update_lhs()
		rhs_autostring = ExprItemAutostring.new(
			conclusion.get_child(1).get_expr_item(), 
			assumption_statement.get_inner_parse_box(assumption_context.get_parse_box())
		)
		_update_rhs()
		$"%Right".init(assumption, assumption_context, selection_handler, false)
		$"%Left".init(assumption, assumption_context, selection_handler, true)

func _update_lhs():
	$LHS.clear()
	$LHS.add_item(lhs_autostring.get_string())

func _update_rhs():
	$RHS.clear()
	$RHS.add_item(rhs_autostring.get_string())
