extends HBoxContainer


var conditions : Array
var assumption : ExprItem


func initialise(assumption:ExprItem, assumption_context:SymmetryBox, _selection_handler:SelectionHandler):
	self.assumption = assumption
	
	conditions = Statement.new(assumption).get_conditions()
	if conditions.size() > 0:
		show()
		_update_conditions(assumption_context)


func _update_conditions(assumption_context:SymmetryBox):
	for condition in conditions:
		$Conditions.add_item(assumption_context.get_parse_box().printout(condition))
