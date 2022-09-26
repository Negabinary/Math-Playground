extends Justification
class_name ReflexiveJustification


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="ReflexiveJustification"
	}


static func _is_reflexive(expr_item:ExprItem):
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return false
	if not expr_item.get_child(0).compare(expr_item.get_child(1)):
		return false
	return true


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	if _is_reflexive(expr_item):
		return []
	else:
		return null


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return [Justification.LabelOption.new(ConstantAutostring.new("Not an equality!"))]
	if not expr_item.get_child(0).compare(expr_item.get_child(1)):
		return [Justification.LabelOption.new(ConstantAutostring.new("Sides of the equality must be exactly the same!"))]
	return []


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("using reflexivity,")


func _get_all_types() -> Dictionary:
	return {}
