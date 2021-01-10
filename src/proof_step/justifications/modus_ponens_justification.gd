extends Justification
class_name ModusPonensJustification


var implication : Statement


func _init(context:ProofBox, implication:ExprItem):
	self.implication = Statement.new(implication)
	requirements = [PROOF_STEP.new(implication, context)]
	for condition in self.implication.get_conditions():
		requirements.append(PROOF_STEP.new(
			condition.get_expr_item(),
			context
		))


func _verify_expr_item(expr_item:ExprItem) -> bool:
	return implication.get_conclusion().get_expr_item().compare(expr_item) \
	and implication.get_definitions() == []


func get_implication_proof_step():
	return requirements[0]


func get_justification_text():
	return "USING " + get_implication_proof_step().get_statement().to_string()
