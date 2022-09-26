extends Justification
class_name AssumptionJustification


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	return []

func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	return []

func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("by assumption,")

func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="AssumptionJustification"
	}


func _get_all_types() -> Dictionary:
	return {}
