extends EqualityJustification
class_name IntroducedDoubleNegativeJustification


var context : ProofBox
var locator : Locator


static func remove_two_negatives(expr_item:ExprItem) -> ExprItem:
	assert(expr_item.type == GlobalTypes.NOT)
	expr_item = expr_item.get_child(0)
	assert(expr_item.type == GlobalTypes.NOT)
	expr_item = expr_item.get_child(0)
	return expr_item


# locator has a double-negative in it.
func _init(context:ProofBox, locator:Locator) \
			.(context, locator, remove_two_negatives(locator.get_expr_item())):
	requirements.remove(0)

func get_justification_text():
	return "ADDING A DOUBLE NEGATIVE"
