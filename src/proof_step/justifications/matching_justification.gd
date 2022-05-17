extends Justification
class_name MatchingJustification

var lhs : ExprItem
var rhs : ExprItem


static func _get_requirements(context:ProofBox, lhs:ExprItem, rhs:ExprItem):
	var r := []
	for i in lhs.get_child_count():
		r.append(
			Requirement.new(
				context,
				ExprItem.new(GlobalTypes.EQUALITY,[
					lhs.get_child(i),
					rhs.get_child(i)
				])
			)
		)
	return r


func _init(context:ProofBox, lhs:ExprItem, rhs:ExprItem).(
		_get_requirements(context, lhs, rhs)
	):
	self.lhs = lhs
	self.rhs = rhs
	


func can_justify(expr_item:ExprItem):
	return ExprItem.new(GlobalTypes.EQUALITY,[lhs, rhs]).compare(expr_item)


func get_justification_text():
	return "SO THIS MATCHES"
