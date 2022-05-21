extends AbstractEqualityJustification
class_name IntroducedLambdaJustification


func _get_equality_replace_with(what:ExprItem, context:ParseBox):
	if what.get_type() != GlobalTypes.LAMBDA:
		return null
	if what.get_type().get_child_count < 3:
		return null
	var x := what.get_child(1).deep_replace_types({
		what.get_child(0).get_type() : what.get_child(2)
	})
	var y := what.get_children()
	y.pop_front()
	y.pop_front()
	y.pop_front()
	for z in y:
		x = x.apply(z)
	return x


func _get_equality_requirements(what:ExprItem, context:ParseBox):
	if what.get_type() != GlobalTypes.LAMBDA:
		return [Justification.LabelOption.new("That location is not a lambda expression!", true)]
	if what.get_type().get_child_count < 3:
		return [Justification.LabelOption.new("That lambda is not applied to anything!", true)]
	return []


func _get_equality_options(what:ExprItem, context:ParseBox):
	return []


func get_justification_text():
	return "INTRODUCING A FUNCTION"
