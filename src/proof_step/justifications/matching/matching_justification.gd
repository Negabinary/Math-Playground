extends Justification
class_name MatchingJustification

# TODO: Multiple matchings?

func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="MatchingJustification"
	}


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return null
	var lhs := expr_item.get_child(0)
	var rhs := expr_item.get_child(1)
	if lhs.get_child_count() == 0 or rhs.get_child_count() == 0:
		return null
	return [
		Requirement.new(
			ExprItem.new(
				GlobalTypes.EQUALITY,
				[lhs.get_child(lhs.get_child_count()-1), rhs.get_child(rhs.get_child_count()-1)]
			)
		),
		Requirement.new(
			ExprItem.new(
				GlobalTypes.EQUALITY,
				[lhs.abandon_lowest(1), rhs.abandon_lowest(1)]
			)
		)
	]


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return [Justification.LabelOption.new(ConstantAutostring.new("cannot match an expression that is not an equality"), true)]
	var lhs := expr_item.get_child(0)
	var rhs := expr_item.get_child(1)
	if lhs.get_child_count() == 0 or rhs.get_child_count() == 0:
		return [Justification.LabelOption.new(ConstantAutostring.new("cannot match something that is not a function"), true)]
	return []


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("by matching arguments,")


func get_summary(expr_item:ExprItem, context:AbstractParseBox) -> Array:
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return [ConstantAutostring.new("error : not an equality")]
	var lhs := expr_item.get_child(0)
	var rhs := expr_item.get_child(1)
	if lhs.get_child_count() == 0 or rhs.get_child_count() == 0:
		return [ConstantAutostring.new("error : both sides should be functions")]
	return [
		ConstantAutostring.new("by matching"),
		[1,ConstantAutostring.new("two functions")],
		ConstantAutostring.new("and"),
		[0,ConstantAutostring.new("their applications")]
	]
