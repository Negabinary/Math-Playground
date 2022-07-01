extends Justification
class_name ReflexiveJustification


func serialize() -> Dictionary:
	return {
		justification_version=1,
		justification_type="ReflexiveJustification"
	}


func get_requirements_for(expr_item:ExprItem, context:ParseBox):
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return null
	if not expr_item.get_child(0).compare(expr_item.get_child(1)):
		return null
	return []


func get_options_for(expr_item:ExprItem, context:ParseBox):
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return [Justification.LabelOption.new("Not an equality!")]
	if not expr_item.get_child(0).compare(expr_item.get_child(1)):
		return [Justification.LabelOption.new("Sides of the equality must be exactly the same!")]
	return []


func get_justification_text():
	return "using reflexivity,"
