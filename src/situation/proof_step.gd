extends Object
class_name ProofStep


signal justified

var context:ProofStep
#var module:MathModule

var statement:Statement
var justification:Justification
var new_assumptions := []


func _init(new_expr_item:ExprItem, new_justification:Justification = MissingJustification.new(), new_context:ProofStep = null, new_new_assumptions = []):
	statement = Statement.new(new_expr_item)
	justification = new_justification
	context = new_context
	new_assumptions = new_new_assumptions


func get_assumptions() -> Dictionary:
	var assumptions : Dictionary
	if context == null:
		assumptions = {}
	else:
		assumptions = context.get_assumptions()
	for new_assumption in new_assumptions:
		assumptions[new_assumption] = self
	return assumptions


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


func justify_with_assumption() -> void:
	justification = AssumedJustification.new()
	emit_signal("justified")


func justify_with_implication() -> void:
	justification = ImplicationJustification.new(self)
	emit_signal("justified")


func justify_with_vacuous() -> void:
	justification = VacuousJustification.new(self)
	emit_signal("justified")


func justify_with_modus_ponens(implication:ProofStep) -> void:
	justification = ModusPonensJustificaiton.new(self, implication)
	emit_signal("justified")


func justify_with_equality(implication:ProofStep, replace:Locator, with:Locator) -> void:
	justification = EqualityJustification.new(self, implication, replace, with)
	emit_signal("justified")


func justify_with_specialisation(generalised:ProofStep, replace:ExprItemType, replace_with) -> void:
	justification = RefineJustification.new(self, generalised, replace, replace_with)
	emit_signal("justified")


func get_requirements() -> Array:
	return justification.get_requirements()


func _to_string():
	return statement.to_string()


func get_justification_text():
	return justification.get_justification_text()


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


class MissingJustification extends Justification:
	
	func is_proven() -> bool:
		return false
	
	func _init():
		requirements = []


class AssumedJustification extends Justification:
	
	func _init():
		requirements = []


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


class RefineJustification extends Justification:
	
	func _init(
			context:ProofStep,
			generalised:ProofStep,
			replace:ExprItemType,
			with):
		requirements = [generalised]
	
	
	func get_justification_text():
		return "IS THE GENERAL CASE OF"


class ImplicationJustification extends Justification:
	
	func _init(context:ProofStep):
		var new_assumptions = []
		for new_assum in context.get_statement().get_conditions():
			var assum_ps = context.get_script().new(new_assum.get_expr_item())
			assum_ps.justify_with_assumption()
			new_assumptions.append(assum_ps)
		requirements = [
			context.get_script().new(
				context.get_statement().get_conclusion().get_expr_item(),
				MissingJustification.new(),
				context,
				new_assumptions
			)
		]


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
