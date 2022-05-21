extends Justification
class_name MissingJustification 


func get_requirements_for(expr_item:ExprItem, context:ParseBox):
	return null


func get_options_for_selection(expr_item:ExprItem, context:ParseBox, selection:Locator):
	var options := []
	var locator = selection if selection.get_root().compare(expr_item) else null
	var create_lambda_button = Justification.ButtonOption.new("create lambda")
	create_lambda_button.connect("pressed", self, "_request_replace", [
		EliminatedLambdaJustification.new(locator)
	])
	options.append(create_lambda_button)
	var custom_equality_button = Justification.ButtonOption.new("use custom equality")
	custom_equality_button.connect("pressed", self, "_request_replace", [
		EqualityJustification.new(locator)
	])
	options.append(custom_equality_button)
	var prove_implication_button = Justification.ButtonOption.new("prove implication")
	prove_implication_button.connect("pressed", self, "_request_replace", [
		ImplicationJustification.new()
	])
	options.append(prove_implication_button)
	# TODO: Add the rest!
	return options


func _request_replace(justification:Justification):
	emit_signal("request_replace", justification)


func get_justification_text():
	return "JUSTIFICATION MISSING"
