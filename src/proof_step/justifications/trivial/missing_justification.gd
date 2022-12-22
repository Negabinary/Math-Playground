extends Justification
class_name MissingJustification 

func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="MissingJustification"
	}


func get_requirements_for(expr_item:ExprItem):
	return null


func _is_double_negative(expr_item:ExprItem):
	if expr_item:
		if expr_item.get_type() == GlobalTypes.NOT:
			if expr_item.get_child_count() == 1:
				if expr_item.get_child(0).get_type() == GlobalTypes.NOT:
					if expr_item.get_child(0).get_child_count() == 1:
						return true
	return false


func _is_matchable(locator:ExprItem):
	if locator:
		if locator.get_type() == GlobalTypes.EQUALITY:
			if locator.get_child_count() == 2:
				if locator.get_child(0).get_child_count() > 0:
					if locator.get_child(1).get_child_count() > 0:
						return true
	return false


func _get_or_id_start(locator:Locator) -> int:
	if locator == null:
		return -1
	if locator.get_parent() == null:
		return 0
	if locator.get_parent().get_type() == GlobalTypes.OR and locator.get_parent().get_child_count() == 2:
		if locator.get_indeces()[-1] == 0:
			return _get_or_id_start(locator.get_parent())
		else:
			var pr = _get_or_id_start(locator.get_parent())
			if pr == -1:
				return -1
			else:
				return pr + _get_or_id_range(locator.get_parent().get_child(0).get_expr_item())
	return -1


func _get_or_id_range(expr_item:ExprItem) -> int:
	if expr_item.get_type() == GlobalTypes.OR and expr_item.get_child_count() == 2:
		return _get_or_id_range(expr_item.get_child(0)) + _get_or_id_range(expr_item.get_child(1))
	return 1


func _get_or_keep(clauses:int, start:int, length:int) -> Array:
	var result = []
	for k in clauses:
		if k >= start and k < start + length:
			result.append(true)
		else:
			result.append(false)
	return result


func get_options_for_selection(expr_item:ExprItem, context:AbstractParseBox, selection:Locator):
	var options := []
	var locator = (selection if selection.get_root().compare(expr_item) else null) if selection else null
	
	var suggested_option_datas = [
		[
			"assume / instantiate", 
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
			"proof by contradiction",
			expr_item.get_type() == GlobalTypes.NOT,
			load("res://ui/theme/descriptive_buttons/vacuous.tres"),
			ContradictionJustification.new()
		],
		[
			"prove a part of this disjunction",
			expr_item.get_type() == GlobalTypes.OR and _get_or_id_start(locator) == -1,
			load("res://ui/theme/descriptive_buttons/vacuous.tres"),
			OneOfJustification.new(_get_or_keep(_get_or_id_range(expr_item), 0, 0))
		],
		[
			"prove this part of the disjunction",
			expr_item.get_type() == GlobalTypes.OR and _get_or_id_start(locator) != -1,
			load("res://ui/theme/descriptive_buttons/vacuous.tres"),
			OneOfJustification.new(_get_or_keep(_get_or_id_range(expr_item), _get_or_id_start(locator), _get_or_id_range(locator.get_expr_item()))) if locator else null
		],
		[
			"use a witness",
			expr_item.get_type() == GlobalTypes.EXISTS,
			load("res://ui/theme/descriptive_buttons/witness.tres"),
			WitnessJustification.new()
		],
		[
			"prove both directions",
			expr_item.get_type() == GlobalTypes.EQUALITY,
			load("res://ui/theme/descriptive_buttons/witness.tres"),
			BothDirectionsJustification.new()
		],
		[
			"prove all sides of the 'and's",
			expr_item.get_type() == GlobalTypes.AND,
			load("res://ui/theme/descriptive_buttons/witness.tres"),
			CombineJustification.new()
		],
		[
			"eliminate a double negative",
			_is_double_negative(expr_item),
			load("res://ui/theme/descriptive_buttons/double_negative.tres"),
			IntroducedDoubleNegativeJustification.new()
		],
		[
			"equality is reflexive",
			ReflexiveJustification._is_reflexive(expr_item),
			load("res://ui/theme/descriptive_buttons/reflexive.tres"),
			ReflexiveJustification.new()
		],
		[
			"match function arguments",
			_is_matchable(expr_item),
			load("res://ui/theme/descriptive_buttons/matching.tres"),
			MatchingJustification.new()
		],
		[
			"reduce selected lambda expression",
			locator != null and locator.get_type() == GlobalTypes.LAMBDA and locator.get_child_count() > 2,
			load("res://ui/theme/descriptive_buttons/introduced_lambda.tres"),
			IntroducedLambdaJustification.new(locator)
		]
	]
	
	var option_datas = [
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
			"use a custom case split",
			true,
			load("res://ui/theme/descriptive_buttons/refine.tres"),
			CaseSplitJustification.new()
		],
		[
			"prove this and something else",
			true,
			load("res://ui/theme/descriptive_buttons/refine.tres"),
			FromConjunctionJustification.new()
		],
		[
			"use an existential",
			true,
			load("res://ui/theme/descriptive_buttons/instantiate.tres"),
			InstantiateJustification.new()
		],
		[
			"use an equality here",
			locator != null,
			load("res://ui/theme/descriptive_buttons/equality.tres"),
			EqualityJustification.new(locator)
		],
		[
			"expand this into a lambda expression",
			locator != null,
			load("res://ui/theme/descriptive_buttons/eliminated_lambda.tres"),
			EliminatedLambdaJustification.new(locator)
		]
	]
	
	options.append(Justification.LabelOption.new(ConstantAutostring.new(
		"Suggested Strategies:"
	)))
	
	for option_data in suggested_option_datas:
		if option_data[1]:
			var bn = Justification.ButtonOption.new(
				ConstantAutostring.new(option_data[0])
			)
			bn.connect("pressed", self, "_request_replace", [
				option_data[3]
			])
			options.append(bn)
	
	if options.size() == 1:
		options.clear()
	
	options.append(Justification.LabelOption.new(ConstantAutostring.new(
		"Other Strategies:"
	)))
	
	for option_data in option_datas:
		var bn = Justification.ButtonOption.new(
			ConstantAutostring.new(option_data[0]), not option_data[1]
		)
		bn.connect("pressed", self, "_request_replace", [
			option_data[3]
		])
		options.append(bn)
	
	return options


func _request_replace(justification:Justification):
	emit_signal("request_replace", justification)


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("missing justification")


func _get_all_types() -> Dictionary:
	return {}
