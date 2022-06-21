extends Justification
class_name CircularJustification


func serialize() -> Dictionary:
	return {
		justification_version=1,
		justification_type="CircularJustification"
	}


func get_requirements_for(expr_item:ExprItem, context:ParseBox):
	return null


func get_options_for_selection(expr_item:ExprItem, context:ParseBox, selection:Locator):
	return [
		Justification.LabelOption.new(
			"Proof is circlar. Delete the last step."
		)
	]


func get_justification_text():
	return "CIRCULAR JUSTIFICATION"
