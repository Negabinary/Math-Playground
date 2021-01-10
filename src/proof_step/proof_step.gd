extends Object
class_name ProofStep


signal justified


var outer_box : ProofBox
var statement:Statement
var justification:Justification


func _init(new_expr_item:ExprItem, proof_box=null, new_justification:Justification = MissingJustification.new()):
	statement = Statement.new(new_expr_item)
	outer_box = proof_box
	justification = new_justification
	
	if justification is MissingJustification:
		attempt_auto_tag_proof()


func get_proof_box() -> ProofBox:
	return outer_box


func get_module():
	return outer_box.get_module()


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


func is_tag():
	return get_proof_box().is_tag(get_statement().as_expr_item().abandon_lowest(1)) if statement.as_expr_item().get_child_count() > 0 else false


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
	justification = MissingJustification.new()
	emit_signal("justified")


func justify_with_assumption(proof_box:ProofBox) -> void:
	justification = AssumptionJustification.new(proof_box)
	emit_signal("justified")


func justify_with_module_assumption(math_module) -> void:
	justification = AssumptionJustification.new(math_module.get_proof_box())
	emit_signal("justified")


func justify_with_implication() -> void:
	justification = ImplicationJustification.new(self)
	emit_signal("justified")


func justify_with_reflexivity() -> void:
	justification = ReflexiveJustification.new()
	emit_signal("justified")


func justify_with_matching() -> void:
	justification = MatchingJustification.new(self)
	emit_signal("justified")


func justify_with_vacuous() -> void:
	justification = VacuousJustification.new(self)
	emit_signal("justified")


func justify_with_contrapositive() -> void:
	justification = ContrapositiveJustification.new(self)
	emit_signal("justified")


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
			justification = implication.justification
			emit_signal("justified")
		else:
			justification = ModusPonensJustification.new(self, implication)
			emit_signal("justified")
	else:
		var matching := {}
		if does_conclusion_match_with_sub(implication, matching):
			if implication.get_statement().get_conditions().size() == 0:
				justify_with_specialisation(implication, matching)
			else:
				var refined_ps = get_script().new(implication.get_statement().deep_replace_types(matching).as_expr_item(), outer_box)
				refined_ps.justify_with_specialisation(implication, matching)
				justification = ModusPonensJustification.new(self, refined_ps)
				emit_signal("justified")
		else:
			assert(false)


func justify_with_equality(implication:ProofStep, replace_idx:int, with_idx:int, replace_ps:Locator) -> void:
	assert(implication.get_statement().get_conclusion().get_type() == GlobalTypes.EQUALITY)
	var replace_impl := implication.get_statement().get_conclusion().get_child(replace_idx)
	var with := implication.get_statement().get_conclusion().get_child(with_idx)
	if replace_impl.get_expr_item().compare(replace_ps.get_expr_item()):
		justification = EqualityJustification.new(self, implication, replace_ps, with)
		emit_signal("justified")
	else:
		var matching := {}
		for definition in implication.get_statement().get_definitions():
			matching[definition] = "*"
		if replace_impl.get_expr_item().is_superset(replace_ps.get_expr_item(), matching):
			var refined_ps = get_script().new(implication.get_statement().deep_replace_types(matching).as_expr_item(), outer_box)
			refined_ps.justify_with_specialisation(implication, matching)
			justification = EqualityJustification.new(self, refined_ps, replace_ps, refined_ps.get_statement().get_conclusion().get_child(with_idx))
			emit_signal("justified")
		else:
			assert(false)


func justify_with_specialisation(generalised:ProofStep, matching) -> void:
	justification = RefineJustification.new(self, generalised, matching)
	emit_signal("justified")


func justify_with_generalisation(new_identifier:String) -> void:
	justification = RefineJustification.new(self, new_identifier, {})
	emit_signal("justified")


func justify_with_instantiation(existential, new_type) -> void:
	justification = InstantiateJustification.new(self, existential, new_type)
	emit_signal("justified")


func justify_with_create_lambda(location:Locator, argument_locations:Array, argument_types:Array, argument_values:Array): #Array<ExprItemType> # Array<Array<Locator>> 
	justification = EliminatedLambdaJustification.new(self, location, argument_locations, argument_types, argument_values)
	emit_signal("justified")


func justify_with_destroy_lambda(location:Locator):
	assert (location.get_type() == GlobalTypes.LAMBDA)
	assert (location.get_child_count() >= 3)
	justification = IntroducedLambdaJustification.new(self, location)
	emit_signal("justified")



func get_requirements() -> Array:
	return justification.get_requirements()


func _to_string():
	return statement.to_string()


func get_justification_text():
	return justification.get_justification_text()


func clear_justification():
	justification = MissingJustification.new()
	emit_signal("justified")


func attempt_auto_tag_proof() -> void:
	if statement.as_expr_item().get_child_count() > 0:
		var proof_box = get_proof_box()
		if proof_box.is_tag(statement.as_expr_item().abandon_lowest(1)):
			if proof_box.find_tag(statement.as_expr_item().get_child(statement.as_expr_item().get_child_count()-1), statement.as_expr_item()) != null:
				justify_with_assumption(proof_box)



class ModusPonensJustification extends Justification:
	
	var implication:ProofStep
	
	func _init(context:ProofStep, new_implication:ProofStep):
		implication = new_implication
		requirements = [implication]
		for assumption in implication.statement.get_conditions():
			requirements.append(
					new_implication.get_script().new(
							assumption.get_expr_item(),
							context.get_proof_box(),
							MissingJustification.new()
					)
			)
	
	func get_justification_text():
		return "USING " + requirements[0].get_statement().to_string()


class EqualityJustification extends Justification:
#
	func _init(
			context:ProofStep,
			new_equality:ProofStep, 
			replace:Locator, # Within parent CONCLUSION
			with:Locator): # Within equality
		var equality = new_equality
		requirements = [equality]
		for assumption in equality.statement.get_conditions():
			requirements.append(
					equality.get_script().new(
							assumption.get_expr_item(),
							context.get_proof_box(),
							MissingJustification.new()
					)
			)
		var with_replacement = context.get_conclusion().get_expr_item().replace_at(replace.get_indeces(), with.get_expr_item())
		requirements.append(equality.get_script().new(with_replacement, context.get_proof_box(), MissingJustification.new()))

	func get_justification_text():
		return "USING " + requirements[0].get_statement().to_string()	


class RefineJustification extends Justification:
	
	func _init(
			context:ProofStep,
			generalised,
			_matching:Dictionary):
		if generalised is String:
			var new_type = ExprItemType.new(generalised)
			var new_ei = ExprItem.new(
				GlobalTypes.FORALL, [
					ExprItem.new(new_type),
					context.get_statement().as_expr_item()
				]
			)
			requirements = [context.get_script().new(
				new_ei,
				context.get_proof_box(),
				MissingJustification.new()
			)]
		else:
			requirements = [generalised]
	
	
	func get_justification_text():
		return "IS THE GENERAL CASE OF"



class InstantiateJustification extends Justification:
	
	func _init(context:ProofStep, existential:ProofStep, new_type:ExprItemType=null):
		var context_ei = context.get_statement().as_expr_item()
		var existential_ei = existential.get_statement().as_expr_item()
		assert (existential_ei.get_type() == GlobalTypes.EXISTS)
		var old_type = existential_ei.get_child(0).get_type()
		if new_type == null:
			new_type = ExprItemType.new(old_type.get_identifier())
		var new_assumption = context.get_script().new(existential_ei.get_child(1).deep_replace_types({old_type:ExprItem.new(new_type)}), context.get_proof_box(), context)
		new_assumption.justify_with_assumption()
		var new_proof_box = ProofBox.new([new_type],context.get_proof_box())
		new_proof_box.add_assumption(new_assumption)
		requirements = [
			existential,
			context.get_script().new(
				context_ei,
				new_proof_box,
				MissingJustification.new()
			)
		]
	
	func get_justification_text():
		return "THUS"


# keep_exists_types is an array where each index has an array of the types kept
class ImplicationJustification extends Justification:
	
	func _init(context:ProofStep, keep_condition_ids:=[], keep_forall_ids:=[], keep_exists_types:=[]):
		var conclusion = context.get_statement().get_conclusion().get_expr_item()
		var ctxt_assumptions = []
		var ctxt_definitions = context.get_statement().get_definitions().duplicate()
		var conditions := context.get_statement().get_conditions()
		for i in range( context.get_statement().get_conditions().size()-1, -1, -1):
			if i in keep_condition_ids:
				conclusion = ExprItem.new(GlobalTypes.IMPLIES, [conditions[i],conclusion])
			else:
				var assum_ei:ExprItem
				if keep_exists_types.size() <= i:
					assum_ei = strip_existential(ctxt_definitions, conditions[i].get_expr_item(), [])
				else:
					assum_ei = strip_existential(ctxt_definitions, conditions[i].get_expr_item(), keep_exists_types[i])
				var assum_ps = context.get_script().new(assum_ei, context.get_proof_box())
				assum_ps.justify_with_assumption(context.get_proof_box())
				ctxt_assumptions.append(assum_ps)
		var new_proof_box = ProofBox.new(ctxt_definitions, context.get_proof_box())
		for ctxt_assumption in ctxt_assumptions:
			new_proof_box.add_assumption(ctxt_assumption)
		requirements = [
			context.get_script().new(
				conclusion,
				new_proof_box,
				MissingJustification.new()
			)
		]
	
	static func strip_existential(return_types:Array, expr_item:ExprItem, keep_ids:=[]):
		var counter = 0
		var keepers = []
		while expr_item.get_type() == GlobalTypes.EXISTS:
			if counter in keep_ids:
				keepers.push_front(expr_item.get_child(0).get_type())
			else:
				return_types.append(expr_item.get_child(0).get_type())
			expr_item = expr_item.get_child(1)
			counter += 1
		for keeper in keepers:
			expr_item = ExprItem.new(GlobalTypes.EXISTS, [ExprItem.new(keeper), expr_item])
		return expr_item

	func get_justification_text():
		return "THUS"


class ReflexiveJustification extends Justification:
	
	func _init():
		requirements = []
	
	func get_justification_text():
		return "BECAUSE ANYTHING EQUALS ITSELF"


class MatchingJustification extends Justification:
	
	func _init(context:ProofStep):
		requirements = []
		var lhs := context.get_statement().as_expr_item().get_child(0)
		var rhs := context.get_statement().as_expr_item().get_child(1)
		for i in lhs.get_child_count():
			requirements.append(
				context.get_script().new(
					ExprItem.new(GlobalTypes.EQUALITY,[
						lhs.get_child(i),
						rhs.get_child(i)
					]),
					context.get_proof_box(),
					MissingJustification.new()
				)
			)
	
	func get_justification_text():
		return "SO THIS MATCHES"


class VacuousJustification extends Justification:
	
	func _init(context:ProofStep):
		requirements = [
			context.get_script().new(
				context.get_statement().as_expr_item().get_child(0).negate(),
				context.get_proof_box(),
				MissingJustification.new()
			)
		]
	
	func get_justification_text():
		return "MAKES THE FOLLOWING VACUOUS"


class ContrapositiveJustification extends Justification:
	
	func _init(context:ProofStep):
		var expr_item := context.get_statement().as_expr_item()
		var lhs := expr_item.get_child(0)
		var rhs := expr_item.get_child(1)
		if lhs.get_type() == GlobalTypes.NOT:
			lhs = lhs.get_child(0)
		else:
			lhs = ExprItem.new(GlobalTypes.NOT, [lhs])
		if rhs.get_type() == GlobalTypes.NOT:
			rhs = rhs.get_child(0)
		else:
			rhs = ExprItem.new(GlobalTypes.NOT, [rhs])
		expr_item = ExprItem.new(GlobalTypes.IMPLIES, [rhs, lhs])
		requirements = [
			context.get_script().new(
				expr_item,
				context.get_proof_box(),
				MissingJustification.new()
			)
		]


class EliminatedLambdaJustification extends Justification:
	func _init(context:ProofStep, location:Locator, argument_locations:Array, argument_types:Array, argument_values:Array): #Array<ExprItemType> # Array<Array<Locator>> 
		requirements = [context.get_script().new(
			ExprItemLambdaHelper.create_lambda(location, argument_locations, argument_types, argument_values),
			context.get_proof_box(),
			MissingJustification.new()
		)]
	
	func get_justification_text():
		return "APPLYING A FUNCTION"



class IntroducedLambdaJustification extends Justification:
	func _init(context:ProofStep, location:Locator): #Array<ExprItemType> # Array<Array<Locator>> 
		requirements = [context.get_script().new(
			ExprItemLambdaHelper.apply_lambda(location),
			context.get_proof_box(),
			MissingJustification.new()
		)]
	
	func get_justification_text():
		return "INTRODUCING A FUNCTION"
