extends HBoxContainer


var conditions : Array
var condition_strings : Autostring
var assumption : ExprItem


func initialise(assumption:ExprItem, assumption_context:SymmetryBox, _selection_handler:SelectionHandler):
	self.assumption = assumption
	var statement := Statement.new(assumption)
	conditions = statement.get_conditions()
	var inner_pb = statement.get_inner_parse_box(assumption_context.get_parse_box())
	for condition in conditions:
		var autostring := ExprItemAutostring.new(condition, inner_pb)
		condition_strings.append(autostring)
		autostring.connect("updated", self, "_update_conditions")
	
	if conditions.size() > 0:
		show()
		_update_conditions(assumption_context)


func _update_conditions(assumption_context:SymmetryBox):
	for autostring in condition_strings:
		$Conditions.add_item(autostring.get_string())
