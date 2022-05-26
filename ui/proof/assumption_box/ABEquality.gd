extends HBoxContainer


var conditions : Array
var assumption : ExprItem
var selection_handler : SelectionHandler


func initialise(assumption:ExprItem, assumption_context:ProofBox, selection_handler:SelectionHandler):
	self.assumption = assumption
	self.selection_handler = selection_handler
	
	var assumption_statement := Statement.new(assumption)
	var conclusion:Locator = assumption_statement.get_conclusion()
	var definitions := assumption_statement.get_definitions()
	
	if conclusion.get_type() == GlobalTypes.EQUALITY:
		show()
		$Equalities.add_equalities(conclusion)
		$Equalities.definitions = definitions
