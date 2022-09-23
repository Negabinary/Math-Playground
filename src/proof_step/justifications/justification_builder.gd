class_name JustificationBuilder

static func deserialize(j:Dictionary, parse_box:AbstractParseBox, version) -> Justification:
	match j:
		{"justification_type": "AssumptionJustification", ..}:
			return null
		{"justification_type": "BothDirectionsJustification", ..}:
			return BothDirectionsJustification.new()
		{"justification_type": "CaseSplitJustification", ..}:
			return CaseSplitJustification.new(
				ExprItemBuilder.deserialize(j.disjunction, parse_box)
			)
		{"justification_type": "CombineJustification", ..}:
			return CombineJustification.new()
		{"justification_type": "EliminatedLambdaJustification", ..}:
			var locator := Locator.new(
				ExprItemBuilder.deserialize(j.location_expr_item, parse_box),
				j.location_indeces
			)
			return EliminatedLambdaJustification.new(
				locator,
				ExprItemBuilder.deserialize(j.replace_value, locator.get_parse_box(parse_box)),
				ExprItemType.new(j.replace_with),
				j.replace_positions
			)
		{"justification_type": "EqualityJustification", ..}:
			var locator := Locator.new(
				ExprItemBuilder.deserialize(j.location_expr_item, parse_box),
				j.location_indeces
			)
			return EqualityJustification.new(
				locator,
				ExprItemBuilder.deserialize(j.replace_with, locator.get_parse_box(parse_box)),
				j.forwards
			)
		{"justification_type": "FromConjunctionJustification", ..}:
			return FromConjunctionJustification.new(
				ExprItemBuilder.deserialize(j.conjunction, parse_box)
			)
		{"justification_type": "ImplicationJustification", ..}:
			return ImplicationJustification.new(
				j.keep_definition_ids,
				j.keep_condition_ids
			)
		{"justification_type": "InstantiateJustification", ..}:
			return InstantiateJustification.new(
				j.new_type,
				ExprItemBuilder.deserialize(j.existential, parse_box)
			)
		{"justification_type": "IntroducedDoubleNegativeJustification", ..}:
			return IntroducedDoubleNegativeJustification.new(
				Locator.new(
					ExprItemBuilder.deserialize(j.location_expr_item, parse_box),
					j.location_indeces
				)
			)
		{"justification_type": "IntroducedLambdaJustification", ..}:
			return IntroducedLambdaJustification.new(
				Locator.new(
					ExprItemBuilder.deserialize(j.location_expr_item, parse_box),
					j.location_indeces
				)
			)
		{"justification_type": "MatchingJustification", ..}:
			return MatchingJustification.new()
		{"justification_type": "MissingJustification", ..}:
			return null
		{"justification_type": "ModusPonensJustification", ..}:
			return ModusPonensJustification.new(
				ExprItemBuilder.deserialize(j.implication, parse_box)
			)
		{"justification_type": "RefineJustification", ..}:
			return RefineJustification.new(
				ExprItemBuilder.deserialize(j.general, parse_box)
			)
		{"justification_type": "ReflexiveJustification", ..}:
			return ReflexiveJustification.new()
		{"justification_type": "SeparateBiimplicationJustification", ..}:
			return SeparateBiimplicationJustification.new(j.indeces, j.left)
		{"justification_type": "VacuousJustification", ..}:
			return VacuousJustification.new()
		{"justification_type": "WitnessJustification", ..}:
			return WitnessJustification.new(
				ExprItemBuilder.deserialize(j.witness, parse_box)
			)
	return null
