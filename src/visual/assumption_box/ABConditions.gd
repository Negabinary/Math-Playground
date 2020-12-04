extends HBoxContainer


var conditions : Array
var assumption : ProofStep
var selection_handler : SelectionHandler


func initialise(assumption:ProofStep, selection_handler:SelectionHandler):
	self.assumption = assumption
	self.selection_handler = selection_handler
	
	conditions = assumption.get_statement().get_conditions()
	if conditions.size() > 0:
		show()
		_update_conditions(conditions)


func _update_conditions(conditions:Array):
	for i in conditions.size():
		var condition : UniversalLocator = UniversalLocator.new(assumption.get_statement(), conditions[i])
		$Conditions.add_item(condition.to_string())

