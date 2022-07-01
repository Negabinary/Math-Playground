extends Justification
class_name VacuousJustification 


func serialize() -> Dictionary:
	return {
		justification_version=1,
		justification_type="VacuousJustification"
	}


func get_requirements_for(expr_item:ExprItem, context:ParseBox):
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


func get_options_for(expr_item:ExprItem, context:ParseBox):
	if expr_item.get_type() != GlobalTypes.IMPLIES or expr_item.get_child_count() != 2:
		return [Justification.LabelOption.new("Not an implication!", true)]
	return []


func get_justification_text():
	return "so the following is vacuous,"
