extends Object
class_name ProofStep


signal justified


var context:ProofStep
#var module:MathModule

var statement:Statement
var justification:Justification
var new_assumptions := []
var new_definitions := []


func _init(new_expr_item:ExprItem, new_justification:Justification = MissingJustification.new(), new_context:ProofStep = null, new_new_assumptions = [], new_new_definitions = []):
	statement = Statement.new(new_expr_item)
	justification = new_justification
	context = new_context
	new_assumptions = new_new_assumptions
	new_definitions = new_new_definitions


func get_assumptions() -> Dictionary:
	var assumptions : Dictionary
	if context == null:
		assumptions = {}
	else:
		assumptions = context.get_assumptions()
	for new_assumption in new_assumptions:
		assumptions[new_assumption] = self
	return assumptions


func get_definitions() -> Array:
	var definitions : Array
	if context == null:
		definitions = []
	else:
		definitions = context.get_definitions()
	for new_definition in new_definitions:
		definitions.push_front(new_definition)
	return definitions


func get_statement() -> Statement:
	return statement


func get_conclusion() -> Locator:
	return statement.get_conclusion()


func needs_justification() -> bool:
	return justification is MissingJustification


func is_proven() -> bool:
	return justification.is_proven()


func _get_justification() -> Justification:
	return justification


func does_conclusion_match_exactly(assumption:ProofStep) -> bool:
	return statement.as_expr_item().compare(assumption.get_statement().get_conclusion().get_expr_item())


func does_conclusion_match_with_sub(assumption:ProofStep, empty_matching:={}) -> bool:
	var matching := empty_matching
	for definition in assumption.get_statement().get_definitions():
		matching[definition] = "*"
	return assumption.get_statement().get_conclusion().get_expr_item().is_superset(statement.as_expr_item(), matching)


func can_justify_with_assumption(assumption:ProofStep) -> bool:
	if not (assumption in get_assumptions()):
		return false
	elif does_conclusion_match_exactly(assumption):
		return true # Matches exactly
	else:
		return does_conclusion_match_with_sub(assumption)


func justify_with_assumption() -> void:
	justification = AssumedJustification.new()
	emit_signal("justified")


func justify_with_module(math_module) -> void:
	justification = ModuleJustification.new(math_module)
	emit_signal("justified")


func justify_with_implication() -> void:
	justification = ImplicationJustification.new(self)
	emit_signal("justified")


func justify_with_reflexivity() -> void:
	justification = ReflexiveJustification.new()
	emit_signal("justified")


func justify_with_vacuous() -> void:
	justification = VacuousJustification.new(self)
	emit_signal("justified")


func justify_with_contrapositive() -> void:
	justification = ContrapositiveJustification.new(self)
	emit_signal("justified")


func can_justify_with_modus_ponens(assumption:ProofStep) -> bool:
	if not (assumption in get_assumptions()):
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
			justification = ModusPonensJustificaiton.new(self, implication)
			emit_signal("justified")
	else:
		var matching := {}
		if does_conclusion_match_with_sub(implication, matching):
			if implication.get_statement().get_conditions().size() == 0:
				justify_with_specialisation(implication, matching)
			else:
				var refined_ps = get_script().new(implication.get_statement().deep_replace_types(matching).as_expr_item())
				refined_ps.justify_with_specialisation(implication, matching)
				justification = ModusPonensJustificaiton.new(self, refined_ps)
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
			var refined_ps = get_script().new(implication.get_statement().deep_replace_types(matching).as_expr_item())
			refined_ps.justify_with_specialisation(implication, matching)
			justification = EqualityJustification.new(self, refined_ps, replace_ps, refined_ps.get_statement().get_conclusion().get_child(with_idx))
			emit_signal("justified")
		else:
			assert(false)



#func does_conclusion_match_with_sub(assumption:ProofStep, empty_matching:={}) -> bool:
#	var matching := empty_matching
#	for definition in assumption.get_statement().get_definitions():
#		matching[definition] = "*"
#	return assumption.get_statement().get_conclusion().get_expr_item().is_superset(statement.as_expr_item(), matching)


func justify_with_specialisation(generalised:ProofStep, matching) -> void:
	justification = RefineJustification.new(self, generalised, matching)
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


class Justification:
	
	var requirements : Array
	
	func is_proven() -> bool:
		var proven := true
		for requirement in requirements:
			if !requirement._get_justification().is_proven():
				proven = false
				break
		return proven
	
	func get_requirements() -> Array: # <ProofStep>
		return requirements
	
	func get_justification_text():
		return "Justification Text Not Implemented"


class MissingJustification extends Justification:
	
	func is_proven() -> bool:
		return false
	
	func _init():
		requirements = []
		
	func get_justification_text():
		return "MISSING JUSTIFICATION"


class AssumedJustification extends Justification:
	
	func _init():
		requirements = []
	
	func get_justification_text():
		return "ASSUMED"


class ModuleJustification extends Justification:
	
	var module # : MathModule
	
	func _init(new_module):
		requirements = []
		module = new_module
	
	func get_justification_text():
		return "ASSUMED IN MODULE"


class ModusPonensJustificaiton extends Justification:
	
	var implication:ProofStep
	
	func _init(context:ProofStep, new_implication:ProofStep):
		implication = new_implication
		requirements = [implication]
		for assumption in implication.statement.get_conditions():
			requirements.append(
					new_implication.get_script().new(
							assumption.get_expr_item(),
							MissingJustification.new(),
							context
					)
			)
	
	func get_justification_text():
		return "USING " + requirements[0].get_statement().to_string()
#
#
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
							MissingJustification.new(),
							context
					)
			)
		var with_replacement = context.get_conclusion().get_expr_item().replace_at(replace.get_indeces(), with.get_expr_item())
		requirements.append(equality.get_script().new(with_replacement, MissingJustification.new(), context))

	func get_justification_text():
		return "USING " + requirements[0].get_statement().to_string()	


class RefineJustification extends Justification:
	
	func _init(
			_context:ProofStep,
			generalised:ProofStep,
			_matching:Dictionary):
		requirements = [generalised]
	
	
	func get_justification_text():
		return "IS THE GENERAL CASE OF"


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
				var assum_ps = context.get_script().new(assum_ei)
				assum_ps.justify_with_assumption()
				ctxt_assumptions.append(assum_ps)
		requirements = [
			context.get_script().new(
				conclusion,
				MissingJustification.new(),
				context,
				ctxt_assumptions
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


class VacuousJustification extends Justification:
	
	func _init(context:ProofStep):
		requirements = [
			context.get_script().new(
				context.get_statement().as_expr_item().get_child(0).negate(),
				MissingJustification.new(),
				context
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
				MissingJustification.new(),
				context
			)
		]
