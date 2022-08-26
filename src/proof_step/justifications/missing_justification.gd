extends Justification
class_name MissingJustification 

func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="MissingJustification"
	}


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	return null


func _is_double_negative(locator:Locator):
	if locator:
		if locator.get_type() == GlobalTypes.NOT:
			if locator.get_child_count() == 1:
				if locator.get_child(0).get_type() == GlobalTypes.NOT:
					if locator.get_child(0).get_child_count() == 1:
						return true
	return false


func _is_matchable(locator:Locator):
	if locator:
		if locator.get_type() == GlobalTypes.EQUALITY:
			if locator.get_child_count() == 2:
				if locator.get_child(0).get_child_count() > 0:
					if locator.get_child(1).get_child_count() > 0:
						return true
	return false


func get_options_for_selection(expr_item:ExprItem, context:AbstractParseBox, selection:Locator):
	var options := []
	var locator = (selection if selection.get_root().compare(expr_item) else null) if selection else null
	
	var option_datas = [
		[
			"prove implication", 
			expr_item.get_type() == GlobalTypes.FORALL or expr_item.get_type() == GlobalTypes.IMPLIES,
			load("res://ui/theme/descriptive_buttons/implication.tres"),
			ImplicationJustification.new()
		],
		[
			"prove this implication vacuous",
			expr_item.get_type() == GlobalTypes.IMPLIES,
			load("res://ui/theme/descriptive_buttons/vacuous.tres"),
			VacuousJustification.new()
		],
		[
			"use a custom implication",
			true,
			load("res://ui/theme/descriptive_buttons/modus_ponens.tres"),
			ModusPonensJustification.new()
		],
		[
			"prove a more general version",
			true,
			load("res://ui/theme/descriptive_buttons/refine.tres"),
			RefineJustification.new()
		],
		[
			"use an existential",
			true,
			load("res://ui/theme/descriptive_buttons/instantiate.tres"),
			InstantiateJustification.new()
		],
		[
			"use a witness",
			expr_item.get_type() == GlobalTypes.EXISTS,
			load("res://ui/theme/descriptive_buttons/witness.tres"),
			WitnessJustification.new()
		],
		[
			"use an equality",
			locator != null,
			load("res://ui/theme/descriptive_buttons/equality.tres"),
			EqualityJustification.new(locator)
		],
		[
			"eliminate a double negative",
			_is_double_negative(locator),
			load("res://ui/theme/descriptive_buttons/double_negative.tres"),
			IntroducedDoubleNegativeJustification.new(locator)
		],
		[
			"match function arguments",
			_is_matchable(locator),
			load("res://ui/theme/descriptive_buttons/matching.tres"),
			IntroducedDoubleNegativeJustification.new(locator)
		],
		[
			"equality is reflexive",
			ReflexiveJustification._is_reflexive(expr_item),
			load("res://ui/theme/descriptive_buttons/reflexive.tres"),
			ReflexiveJustification.new()
		],
		[
			"create lambda",
			locator != null,
			load("res://ui/theme/descriptive_buttons/eliminated_lambda.tres"),
			EliminatedLambdaJustification.new(locator)
		],
		[
			"apply lambda",
			locator != null and locator.get_type() == GlobalTypes.LAMBDA and locator.get_child_count() > 2,
			load("res://ui/theme/descriptive_buttons/introduced_lambda.tres"),
			IntroducedLambdaJustification.new(locator)
		]
	]
	
	for option_data in option_datas:
		var bn = Justification.ButtonOption.new(
			option_data[0], not option_data[1], option_data[2]
		)
		bn.connect("pressed", self, "_request_replace", [
			option_data[3]
		])
		options.append(bn)
	
	var prove_implication_button = Justification.ButtonOption.new("prove implication")
	prove_implication_button.connect("pressed", self, "_request_replace", [
		ImplicationJustification.new()
	])
	options.append(prove_implication_button)
	
	return options


func _request_replace(justification:Justification):
	print("HERE2")
	emit_signal("request_replace", justification)


func get_justification_text(parse_box:AbstractParseBox):
	return "missing justification"
