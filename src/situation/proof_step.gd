extends Object
class_name ProofStep


signal justified

var context:ProofStep
#var module:MathModule

var statement:Statement
var justification:Justification


func _init(new_expr_item:ExprItem, new_justification:Justification = MissingJustification.new(), new_context:ProofStep = null):
	statement = Statement.new(new_expr_item)
	justification = new_justification
	context = new_context


func get_assumptions() -> Dictionary:
	var assumptions : Dictionary
	if context == null:
		assumptions = {}
		print("ay")
	else:
		assumptions = context.get_assumptions()
	for new_assum in statement.get_conditions():
		var assumption_proof_step = get_script().new(new_assum.get_expr_item())
		assumption_proof_step.justify_with_assumption()
		assumptions[assumption_proof_step] = self
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


func justify_with_modus_ponens(implication:ProofStep) -> void:
	justification = ModusPonensJustificaiton.new(self, implication)
	emit_signal("justified")


func justify_with_equality(implication:ProofStep, replace:Locator, with:Locator) -> void:
	justification = EqualityJustification.new(self, implication, replace, with)
	emit_signal("justified")


func get_requirements() -> Array:
	return justification.get_requirements()


func _to_string():
	return statement.to_string()


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

	var equality:ProofStep
	var at:Locator
#
	func _init(
			context:ProofStep,
			new_equality:ProofStep, 
			replace:Locator, # Within parent CONCLUSION
			with:Locator): # Within equality
		equality = new_equality
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


#class SpecializationJusticfication extends Justification:
#
#	var assumption:ProofStep
#	var type_map:Dictionary #<ExprItemType, ExprItem|ExprItemType>
#
#	func _init(new_assumption:ProofStep, new_type_map:Dictionary):
#		assumption = new_assumption
#		type_map = new_type_map
#		requirements = [assumption]
