class_name RequirementJustifier


static func justify_with_missing(r:Requirement) -> void:
	r.justify(MissingJustification.new())


static func justify_with_assumption(r:Requirement) -> void:
	r.justify(AssumptionJustification.new())


static func justify_with_module_assumption(r:Requirement) -> void:
	r.justify(AssumptionJustification.new())


static func justify_with_implication(r:Requirement) -> void:
	r.justify(ImplicationJustification.new(r.get_proof_box(), r.get_goal()))


static func justify_with_reflexivity(r:Requirement) -> void:
	r.justify(ReflexiveJustification.new())


static func justify_with_matching(r:Requirement) -> void:
	r.justify(MatchingJustification.new(r.get_proof_box(), r.get_goal().get_child(0), r.get_goal().get_child(1)))

# TODO: From Here

static func justify_with_vacuous(r:Requirement) -> void:
	r.justify(VacuousJustification.new(r.get_proof_box(), Statement.new(r.get_goal()).get_conditions()[0].get_expr_item()))


static func justify_with_witness(r:Requirement, witness:ExprItem) -> void:
	r.justify(WitnessJustification.new(
		r.get_proof_box(),
		r.get_goal().get_child(0).get_type(),
		r.get_goal().get_child(1),
		witness
	))


static func justify_with_introduced_double_negative(r:Requirement, location:Locator):
	r.justify(IntroducedDoubleNegativeJustification.new(
		r.get_proof_box(),
		location
	))


static func can_justify_with_modus_ponens(r:Requirement, implication:ExprItem) -> bool:
	if not (r.get_proof_box().check_assumption(implication)):
		return false
	elif does_conclusion_match_exactly(r.get_goal(), implication):
		return true
	else:
		return does_conclusion_match_with_sub(r.get_goal(), implication)


static func does_conclusion_match_exactly(expr_item:ExprItem, implication:ExprItem) -> bool:
	return expr_item.compare(Statement.new(implication).get_conclusion().get_expr_item())


static func does_conclusion_match_with_sub(expr_item:ExprItem, implication:ExprItem, empty_matching:={}) -> bool:
	var matching := empty_matching
	for definition in Statement.new(implication).get_definitions():
		matching[definition] = "*"
	return Statement.new(implication).get_conclusion().get_expr_item().is_superset(expr_item, matching)


static func get_statement_justification(r:Requirement, statement_ei:ExprItem): # Justification option
	if statement_ei.get_type() != GlobalTypes.IMPLIES and statement_ei.get_type() != GlobalTypes.FORALL:
		return null
	
	var statement := Statement.new(statement_ei)
	
	var matching := {}
	for definition in Statement.new(implication).get_definitions():
		matching[definition] = "*"
	var can_use_conclusion = Statement.new(implication).get_conclusion().get_expr_item().is_superset(r.get_goal(), matching)
	if can_use_conclusion == false:
		return null
	if "*" in matching.values(): # TODO: This could become an exists?
		return null
	
	for m in matching:
		if matching[m] is ExprItem:
			
	
	var instantiated_implication : ExprItem
	var implication_justification : Justification
	
	
	
	
	var matching := {}
	for definition in Statement.new(implication).get_definitions():
		matching[definition] = "*"
	var can_use_conclusion = Statement.new(implication).get_conclusion().get_expr_item().is_superset(r.get_goal(), matching)
	if can_use_conclusion == false:
		return null
	
	for m in matching:
		if matching[m] is ExprItem:
			
	
	var base_justification = ModusPonensJustification.new(r.get_proof_box(), base_implication)


static func justify_with_modus_ponens(r:Requirement, implication:ExprItem) -> void:
	if does_conclusion_match_exactly(r.get_goal(), implication):
		if Statement.new(implication).get_conditions().size() == 0:
			pass # Hopefully no need to do anything?
		else:
			var j = ModusPonensJustification.new(get_proof_box(), implication.get_statement().as_expr_item())
			j.get_implication_proof_step().justify(implication.get_justification())
			justify(j)
	else:
		var matching := {}
		if does_conclusion_match_with_sub(implication, matching):
			if implication.get_statement().get_conditions().size() == 0:
				justify_with_specialisation(implication, matching)
			else:
				var refined_ei = implication.get_expr_item().deep_replace_types(matching)
				var j = ModusPonensJustification.new(get_proof_box(), refined_ei)
				j.get_implication_proof_step().justify_with_specialisation(implication, matching)
				justify(j)
		else:
			assert(false)


static func justify_with_equality(r:Requirement,implication:ProofStep, replace_idx:int, with_idx:int, replace_ps:Locator) -> void:
	assert(implication.get_statement().get_conclusion().get_type() == GlobalTypes.EQUALITY)
	if implication.get_statement().get_definitions().size() == 0:
		var justification = EqualityJustification.new(
			outer_box, replace_ps,
			implication.get_statement().get_conclusion().get_child(with_idx).get_expr_item(),
			implication.get_statement().get_condition_eis(),
			replace_idx == 0
		)
		justification.get_equality_proof_step().justify(implication.get_justification())
		justify(justification)
	else:
		var matching := {}
		for definition in implication.get_statement().get_definitions():
			matching[definition] = "*"
		var replace_impl := implication.get_statement().get_conclusion().get_child(replace_idx)
		# TODO : Check that foralls aren't lost
		var is_superset = replace_impl.get_expr_item().is_superset(replace_ps.get_expr_item(), matching)
		assert(is_superset)
		
		var specified_statement = Statement.new(implication.get_expr_item().deep_replace_types(matching))
		var justification = EqualityJustification.new(
			outer_box, replace_ps,
			specified_statement.get_conclusion().get_child(with_idx).get_expr_item(),
			specified_statement.get_condition_eis(),
			replace_idx == 0
		)
		justification.get_equality_proof_step().justify_with_specialisation(implication, matching)
		justify(justification)


static func justify_with_specialisation(r:Requirement,generalised:ProofStep, matching) -> void:
	var j = RefineJustification.new(outer_box, generalised.get_statement().as_expr_item(), matching)
	j.get_generalized().justify(generalised.get_justification())
	justify(j)


static func justify_with_generalisation(r:Requirement,new_identifier:String) -> void:
	var new_type := ExprItemType.new(new_identifier)
	var new_statement := ExprItem.new(
		GlobalTypes.FORALL,
		[
			ExprItem.new(new_type),
			get_statement().as_expr_item()
		]
	)
	justify(RefineJustification.new(outer_box, new_statement, {new_type=""}))


static func justify_with_instantiation(r:Requirement,existential) -> void:
	var justification = InstantiateJustification.new(outer_box, existential.get_statement().as_expr_item().get_child(0).get_type().get_identifier(), existential.get_statement().as_expr_item().get_child(0).get_type(), existential.get_statement().as_expr_item().get_child(1), get_statement().as_expr_item())
	justification.get_existential_requirement().justify(existential.get_justification())
	justify(justification)


static func justify_with_create_lambda(r:Requirement,location:Locator, argument_locations:Array, argument_types:Array, argument_values:Array): #Array<ExprItemType> # Array<Array<Locator>> 
	justify(EliminatedLambdaJustification.new(outer_box, location, argument_locations, argument_types, argument_values))


static func justify_with_destroy_lambda(r:Requirement,location:Locator):
	assert (location.get_type() == GlobalTypes.LAMBDA)
	assert (location.get_child_count() >= 3)
	justify(IntroducedLambdaJustification.new(outer_box, location))
