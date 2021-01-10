"""
extends Justification
class_name ModusPonensJustification


var implication : ExprItem


func _init(implication:ExprItem):
	assert(false)


func _verify(proof_step)->bool:
	assert(false)
	return false

"""

"""
class ModusPonensJustificaiton extends Justification:
	
	var implication:ProofStep
	
	func _init(context:ProofStep, new_implication:ProofStep):
		implication = new_implication
		requirements = [implication]
		for assumption in implication.statement.get_conditions():
			requirements.append(
					new_implication.get_script().new(
							assumption.get_expr_item(),
							context.module,
							MissingJustification.new(),
							context
					)
			)
	
	func get_justification_text():
		return "USING " + requirements[0].get_statement().to_string()
"""
