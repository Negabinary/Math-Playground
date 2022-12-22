extends Justification
class_name IntroducedDoubleNegativeJustification


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=2,
		justification_type="IntroducedDoubleNegativeJustification"
	}


func get_requirements_for(expr_item:ExprItem):
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return null
	expr_item = expr_item.get_child(0)
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return null
	expr_item = expr_item.get_child(0)
	return [Requirement.new(expr_item)]


func _get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return [Justification.LabelOption.new(ConstantAutostring.new("That location is not a double negative!"), true)]
	expr_item = expr_item.get_child(0)
	if expr_item.type != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return [Justification.LabelOption.new(ConstantAutostring.new("That location is not not not a double negative!"), true)]
	return []


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("by adding a double negative,")


func _get_all_types() -> Dictionary:
	return {}
