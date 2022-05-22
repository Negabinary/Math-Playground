extends HBoxContainer


var conditions : Array
var assumption : ExprItem


func initialise(assumption:ExprItem, assumption_context:ProofBox, _selection_handler:SelectionHandler):
	self.assumption = assumption
	
	conditions = Statement.new(assumption).get_conditions()
	if conditions.size() > 0:
		show()
		_update_conditions(conditions)


func _update_conditions(conditions:Array):
	for i in conditions.size():
		var condition : UniversalLocator = UniversalLocator.new(assumption.get_statement(), conditions[i])
		$Conditions.add_item(condition.to_string())
