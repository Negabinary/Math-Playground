extends Justification
class_name MissingJustification 


func serialize() -> Dictionary:
	return {
		justification_version=1,
		justification_type="MissingJustification"
	}


func get_requirements_for(expr_item:ExprItem, context:ParseBox):
	return null


func get_options_for_selection(expr_item:ExprItem, context:ParseBox, selection:Locator):
	var options := []
	var locator = (selection if selection.get_root().compare(expr_item) else null) if selection else null
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
	var instantiation_button = Justification.ButtonOption.new("instantiate an existential")
	instantiation_button.connect("pressed", self, "_request_replace",[
		InstantiateJustification.new()
	])
	options.append(instantiation_button)
	var reduce_lambda_button = Justification.ButtonOption.new("reduce lambda")
	reduce_lambda_button.connect("pressed", self, "_request_replace",[
		IntroducedLambdaJustification.new(locator)
	])
	options.append(reduce_lambda_button)
	var reduce_double_negative_button = Justification.ButtonOption.new("reduce double negative")
	reduce_double_negative_button.connect("pressed", self, "_request_replace",[
		IntroducedDoubleNegativeJustification.new(locator)
	])
	options.append(reduce_double_negative_button)
	var matching_button = Justification.ButtonOption.new("match arguments")
	matching_button.connect("pressed", self, "_request_replace",[
		MatchingJustification.new()
	])
	options.append(matching_button)
	var modus_ponens_button = Justification.ButtonOption.new("use an implication")
	modus_ponens_button.connect("pressed", self, "_request_replace", [
		ModusPonensJustification.new()
	])
	options.append(modus_ponens_button)
	var refine_button = Justification.ButtonOption.new("prove a forall")
	refine_button.connect("pressed", self, "_request_replace", [
		RefineJustification.new()
	])
	options.append(refine_button)
	var reflexive_button = Justification.ButtonOption.new("prove a reflexive equality")
	reflexive_button.connect("pressed", self, "_request_replace", [
		ReflexiveJustification.new()
	])
	options.append(reflexive_button)
	var vacuous_justification = Justification.ButtonOption.new("prove this implication vacuous")
	vacuous_justification.connect("pressed", self, "_request_replace", [
		VacuousJustification.new()
	])
	options.append(vacuous_justification)
	var witness_justification = Justification.ButtonOption.new("prove an existential")
	witness_justification.connect("pressed", self, "_request_replace", [
		WitnessJustification.new()
	])
	options.append(witness_justification)
	# TODO: Add the rest!
	return options


func _request_replace(justification:Justification):
	emit_signal("request_replace", justification)


func get_justification_text():
	return "missing justification"
