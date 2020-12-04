extends HBoxContainer


var conditions : Array
var assumption : ProofStep
var selection_handler : SelectionHandler


func initialise(assumption:ProofStep, selection_handler:SelectionHandler):
	self.assumption = assumption
	self.selection_handler = selection_handler
	
	var assumption_statement := assumption.get_statement()
	var conclusion:Locator = assumption_statement.get_conclusion()
	var definitions := assumption_statement.get_definitions()
	
	if conclusion.get_type() == GlobalTypes.EQUALITY:
		show()
		$Equalities.add_equalities(UniversalLocator.new(assumption_statement, conclusion))
		$Equalities.definitions = definitions
