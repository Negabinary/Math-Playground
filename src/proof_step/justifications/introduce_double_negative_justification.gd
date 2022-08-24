extends AbstractEqualityJustification
class_name IntroducedDoubleNegativeJustification


func _init(x).(x):
	pass


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="IntroducedDoubleNegativeJustification",
		location_expr_item=parse_box.serialise(location.get_root()),
		location_indeces=location.get_indeces()
	}


func _get_equality_replace_with(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return null
	expr_item = expr_item.get_child(0)
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return null
	expr_item = expr_item.get_child(0)
	return expr_item


func _get_equality_requirements(what:ExprItem, context:AbstractParseBox):
	return []


func _get_equality_options(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return [Justification.LabelOption.new("That location is not a double negative!", true)]
	expr_item = expr_item.get_child(0)
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return [Justification.LabelOption.new("That location is not not not a double negative!", true)]
	return []


func get_justification_text(parse_box:ParseBox):
	return "by adding a double negative,"
