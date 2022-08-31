extends Justification
class_name VacuousJustification 


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="VacuousJustification"
	}


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.get_type() != GlobalTypes.IMPLIES or expr_item.get_child_count() != 2:
		return null
	return [
		Requirement.new(
			ExprItem.new(
				GlobalTypes.NOT,
				[expr_item.get_child(0)]
			)
		)
	]


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.get_type() != GlobalTypes.IMPLIES or expr_item.get_child_count() != 2:
		return [Justification.LabelOption.new(ConstantAutostring.new("Not an implication!"), true)]
	return []


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("so the following is vacuous,")
