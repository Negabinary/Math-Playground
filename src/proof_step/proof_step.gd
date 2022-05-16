extends Object
class_name ProofStep


signal justified


var outer_box #: ProofBox
var statement:Statement
var justification:Justification


func _init(new_expr_item:ExprItem, proof_box=null, new_justification:Justification = MissingJustification.new()):
	statement = Statement.new(new_expr_item)
	outer_box = proof_box
	justify(new_justification)


func get_proof_box(): #-> ProofBox:
	return outer_box


func get_expr_item() -> ExprItem:
	return get_statement().as_expr_item()


func get_statement() -> Statement:
	return statement


func get_conclusion() -> Locator:
	return statement.get_conclusion()


func needs_justification() -> bool:
	return justification is MissingJustification


func is_proven() -> bool:
	return justification.verify(self)


func get_justification() -> Justification:
	return justification


func serialise():
	return "proofs not serialisable yet..."


func is_tag():
	return get_proof_box().is_tag(get_statement().as_expr_item().abandon_lowest(1)) if statement.as_expr_item().get_child_count() > 0 else false


func justify(justification:Justification):
	if self.justification != null:
		self.justification.disconnect("justified", self, "emit_signal")
	self.justification = justification
	if self.justification != null:
		self.justification.connect("justified", self, "emit_signal", ["justified"])
	emit_signal("justified")


func does_conclusion_match_exactly(assumption:ProofStep) -> bool:
	return statement.as_expr_item().compare(assumption.get_statement().get_conclusion().get_expr_item())


func does_conclusion_match_with_sub(assumption:ProofStep, empty_matching:={}) -> bool:
	var matching := empty_matching
	for definition in assumption.get_statement().get_definitions():
		matching[definition] = "*"
	return assumption.get_statement().get_conclusion().get_expr_item().is_superset(statement.as_expr_item(), matching)


func can_justify_with_assumption(assumption:ProofStep) -> bool:
	if not (outer_box.check_assumption(assumption)):
		return false
	elif does_conclusion_match_exactly(assumption):
		return true # Matches exactly
	else:
		return does_conclusion_match_with_sub(assumption)


func justify_with_missing() -> void:
	justify(MissingJustification.new())


func justify_with_assumption(proof_box:=outer_box) -> void:
	justify(AssumptionJustification.new(proof_box))


func justify_with_module_assumption(math_module) -> void:
	justify(AssumptionJustification.new(math_module.get_proof_box()))


func justify_with_implication() -> void:
	justify(ImplicationJustification.new(outer_box, get_statement()))


func justify_with_reflexivity() -> void:
	justify(ReflexiveJustification.new())


func justify_with_matching() -> void:
	justify(MatchingJustification.new(outer_box, get_statement().as_expr_item().get_child(0), get_statement().as_expr_item().get_child(1)))


func justify_with_vacuous() -> void:
	justify(VacuousJustification.new(outer_box, get_statement().get_conditions()[0].get_expr_item()))


func justify_with_witness(witness:ExprItem) -> void:
	justify(WitnessJustification.new(
		outer_box,
		get_statement().as_expr_item().get_child(0).get_type(),
		get_statement().as_expr_item().get_child(1),
		witness
	))


func justify_with_introduced_double_negative(location:Locator):
	justify(IntroducedDoubleNegativeJustification.new(
		outer_box,
		location
	))


func can_justify_with_modus_ponens(assumption:ProofStep) -> bool:
	if not (outer_box.check_assumption(assumption)):
		return false
	elif does_conclusion_match_exactly(assumption):
		return true
	else:
		return does_conclusion_match_with_sub(assumption)


func justify_with_modus_ponens(implication:ProofStep) -> void:
	if does_conclusion_match_exactly(implication):
		if implication.get_statement().get_conditions().size() == 0:
			justify(implication.justification)
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


func justify_with_equality(implication:ProofStep, replace_idx:int, with_idx:int, replace_ps:Locator) -> void:
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


func justify_with_specialisation(generalised:ProofStep, matching) -> void:
	var j = RefineJustification.new(outer_box, generalised.get_statement().as_expr_item(), matching)
	j.get_generalized().justify(generalised.get_justification())
	justify(j)


func justify_with_generalisation(new_identifier:String) -> void:
	var new_type := ExprItemType.new(new_identifier)
	var new_statement := ExprItem.new(
		GlobalTypes.FORALL,
		[
			ExprItem.new(new_type),
			get_statement().as_expr_item()
		]
	)
	justify(RefineJustification.new(outer_box, new_statement, {new_type=""}))


func justify_with_instantiation(existential) -> void:
	var justification = InstantiateJustification.new(outer_box, existential.get_statement().as_expr_item().get_child(0).get_type().get_identifier(), existential.get_statement().as_expr_item().get_child(0).get_type(), existential.get_statement().as_expr_item().get_child(1), get_statement().as_expr_item())
	justification.get_existential_requirement().justify(existential.get_justification())
	justify(justification)


func justify_with_create_lambda(location:Locator, argument_locations:Array, argument_types:Array, argument_values:Array): #Array<ExprItemType> # Array<Array<Locator>> 
	justify(EliminatedLambdaJustification.new(outer_box, location, argument_locations, argument_types, argument_values))


func justify_with_destroy_lambda(location:Locator):
	assert (location.get_type() == GlobalTypes.LAMBDA)
	assert (location.get_child_count() >= 3)
	justify(IntroducedLambdaJustification.new(outer_box, location))



func get_requirements() -> Array:
	return justification.get_requirements()


func _to_string():
	return statement.to_string()


func get_justification_text():
	return justification.get_justification_text()


func clear_justification():
	justify(MissingJustification.new())