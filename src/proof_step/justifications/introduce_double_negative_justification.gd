extends AbstractEqualityJustification
class_name IntroducedDoubleNegativeJustification


func _get_equality_replace_with(expr_item:ExprItem, context:ParseBox):
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return null
	expr_item = expr_item.get_child(0)
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return null
	expr_item = expr_item.get_child(0)
	return expr_item
	return null


func _get_equality_requirements(what:ExprItem, context:ParseBox):
	return []


func _get_equality_options(expr_item:ExprItem, context:ParseBox):
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return [Justification.LabelOption.new("That location is not a double negative!", true)]
	expr_item = expr_item.get_child(0)
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return [Justification.LabelOption.new("That location is not not not a double negative!", true)]
	return []


func get_justification_text():
	return "ADDING A DOUBLE NEGATIVE"
