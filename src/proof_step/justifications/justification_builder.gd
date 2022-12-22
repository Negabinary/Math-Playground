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
		{"justification_type": "ContradictionJustification", ..}:
			return ContradictionJustification.new(
				ExprItemBuilder.deserialize(j.contradiction, parse_box)
			)
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
			if j.has("definition_identifier_names"):
				return ImplicationJustification.new(
					j.keep_definition_ids,
					j.keep_condition_ids,
					j.definition_identifier_names
				)
			else:
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
			if j.justification_version == 1:
				if j.location_indeces.size() == 0:
					return IntroducedDoubleNegativeJustification.new()
				else:
					return DeprecatedJustification.new("""
						You used the old double-negative justification here, but unfortunately that justification is no longer available. Why? because it used to allow you to prove that if ¬(¬(x)) then  x. It makes intuitive sense, but in short if it's not not true, it isn't necessarily true, because it could be unprovable, or something entirely different like a number. 
						
						If you know that x is a boolean then you can still prove ¬(¬(x)) = x, so you may need to add an assumption that x : bool to fix this proof.
					""")
			else:
				return IntroducedDoubleNegativeJustification.new()
		{"justification_type": "IntroducedLambdaJustification", ..}:
			return IntroducedLambdaJustification.new(
				Locator.new(
					ExprItemBuilder.deserialize(j.location_expr_item, parse_box),
					j.location_indeces
				)
			)
		{"justification_type": "MatchingJustification", ..}:
			if "new_type_name" in j:
				return MatchingJustification.new(ExprItemType.new(j.new_type_name))
			else:
				return MatchingJustification.new(ExprItemType.new("???"))
		{"justification_type": "MissingJustification", ..}:
			return null
		{"justification_type": "ModusPonensJustification", ..}:
			return ModusPonensJustification.new(
				ExprItemBuilder.deserialize(j.implication, parse_box)
			)
		{"justification_type": "OneOfJustification", ..}:
			return OneOfJustification.new(
				j.keep_ids
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
