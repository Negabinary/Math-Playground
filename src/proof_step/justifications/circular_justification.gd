extends Justification
class_name CircularJustification


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="CircularJustification"
	}


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	return null


func get_options_for_selection(expr_item:ExprItem, context:AbstractParseBox, selection:Locator):
	return [
		Justification.LabelOption.new(
			"Proof is circlar. Delete the last step."
		)
	]


func get_justification_text(parse_box:ParseBox):
	return "justification is circular"
