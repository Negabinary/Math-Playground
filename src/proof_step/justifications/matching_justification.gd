extends Justification
class_name MatchingJustification

var lhs : ExprItem
var rhs : ExprItem


func _init(context:ProofBox, lhs:ExprItem, rhs:ExprItem):
	requirements = []
	self.lhs = lhs
	self.rhs = rhs
	for i in lhs.get_child_count():
		requirements.append(
			PROOF_STEP.new(
				ExprItem.new(GlobalTypes.EQUALITY,[
					lhs.get_child(i),
					rhs.get_child(i)
				]),
				context
			)
		)


func _verify_expr_item(expr_item:ExprItem):
	return ExprItem.new(GlobalTypes.EQUALITY,[lhs, rhs]).compare(expr_item)


func get_justification_text():
	return "SO THIS MATCHES"
