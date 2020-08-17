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


func justify_with_implication() -> void:
	justification = ImplicationJustification.new(self)
	emit_signal("justified")


func justify_with_vacuous() -> void:
	justification = VacuousJustification.new(self)
	emit_signal("justified")


func can_justify_with_modus_ponens(assumption:ProofStep) -> bool:
	if not (assumption in get_assumptions()):
		return false
	elif does_conclusion_match_exactly(assumption):
		return true # Matches exactly
	else:
		return does_conclusion_match_with_sub(assumption)


func justify_with_modus_ponens(implication:ProofStep) -> void:
	justification = ModusPonensJustificaiton.new(self, implication)
	emit_signal("justified")


func justify_with_equality(implication:ProofStep, replace:Locator, with:Locator) -> void:
	justification = EqualityJustification.new(self, implication, replace, with)
	emit_signal("justified")


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
