extends EqualityJustification
class_name IntroducedLambdaJustification

var context : ProofBox
var locator : Locator

func _init(context:ProofBox, location:Locator).(context, location, ExprItemLambdaHelper.apply_lambda(location.get_expr_item())):
	requirements.remove(0)

func get_justification_text():
	return "INTRODUCING A FUNCTION"
