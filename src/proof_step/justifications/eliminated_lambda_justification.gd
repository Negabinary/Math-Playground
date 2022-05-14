extends EqualityJustification
class_name EliminatedLambdaJustification

var context : ProofBox
var locator : Locator

func _init(context:ProofBox, location:Locator, argument_locations:Array, 
			argument_types:Array, argument_values:Array
		).(context, location, ExprItemLambdaHelper.create_lambda(location.get_expr_item(), argument_locations, argument_types, argument_values)):
	requirements.remove(0)

func get_justification_text():
	return "APPLYING A FUNCTION"
