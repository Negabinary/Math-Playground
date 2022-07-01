extends Justification
class_name AssumptionJustification


func get_requirements_for(expr_item:ExprItem, context:ParseBox):
	return []

func get_options_for(expr_item:ExprItem, context:ParseBox):
	return []

func get_justification_text():
	return "by assumption,"

func serialize() -> Dictionary:
	return {
		justification_version=1,
		justification_type="AssumptionJustification"
	}
