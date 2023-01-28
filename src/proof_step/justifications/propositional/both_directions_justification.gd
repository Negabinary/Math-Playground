extends Justification
class_name BothDirectionsJustification 


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="BothDirectionsJustification"
	}


func deep_replace_types(matching:Dictionary) -> Justification:
	return get_script().new()


func get_requirements_for(expr_item:ExprItem):
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return null
	return [
		Requirement.new(
			ExprItem.new(
				GlobalTypes.IMPLIES,
				[expr_item.get_child(0), expr_item.get_child(1)]
			)
		),
		Requirement.new(
			ExprItem.new(
				GlobalTypes.IMPLIES,
				[expr_item.get_child(1), expr_item.get_child(0)]
			)
		)
	]


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return [Justification.LabelOption.new(ConstantAutostring.new("Not an equality!"), true)]
	return []


func get_summary(expr_item:ExprItem, context:AbstractParseBox) -> Array:
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return [ConstantAutostring.new("error: not an equality!")]
	else:
		return [
			ConstantAutostring.new("since we can go"),
			[0,ConstantAutostring.new("from left to right")],
			ConstantAutostring.new("and"),
			[1,ConstantAutostring.new("from right to left,")]
		]


func _get_all_types() -> Dictionary:
	return {}
