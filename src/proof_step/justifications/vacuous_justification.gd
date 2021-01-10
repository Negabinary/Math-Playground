extends Justification
class_name VacuousJustification 


var condition : ExprItem


func _init(context:ProofBox, condition:ExprItem):
	self.condition = condition
	requirements = [
		PROOF_STEP.new(
			ExprItem.new(GlobalTypes.NOT, [condition]),
			context
		)
	]


func _verify_expr_item(expr_item:ExprItem) -> bool:
	for condition in Statement.new(expr_item).get_conditions():
		if condition.get_expr_item().compare(expr_item):
			return true
	return false


func get_justification_text():
	return "MAKES THE FOLLOWING VACUOUS"
