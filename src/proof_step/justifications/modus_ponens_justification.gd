extends Justification
class_name ModusPonensJustification


var implication : Statement


static func _get_reqs(context:ProofBox, implication:ExprItem):
	var reqs := [Requirement.new(context, implication)]
	for condition in Statement.new(implication).get_conditions():
		reqs.append(Requirement.new(
			context,
			condition.get_expr_item()
		))
	return reqs


func _init(context:ProofBox, implication:ExprItem).(
		_get_reqs(context, implication)
	):
	self.implication = Statement.new(implication)


func can_justify(expr_item:ExprItem) -> bool:
	return implication.get_conclusion().get_expr_item().compare(expr_item) \
	and implication.get_definitions() == []


func get_implication_proof_step():
	return requirements[0]


func get_justification_text():
	return "USING " + get_implication_proof_step().get_statement().to_string()
