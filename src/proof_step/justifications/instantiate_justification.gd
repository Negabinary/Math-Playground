extends Justification
class_name InstantiateJustification


var type : ExprItemType
var existential : ExprItem
var goal : ExprItem


func _init(context:ProofBox, type:ExprItemType, existential:ExprItem, goal:ExprItem):
	self.type = type
	self.existential = existential
	self.goal = goal
	
	requirements.append(PROOF_STEP.new(
		ExprItem.new(GlobalTypes.EXISTS, [ExprItem.new(type), existential]),
		context
	))
	
	var new_proof_box = ProofBox.new([type],context)
	var assumption = PROOF_STEP.new(existential, new_proof_box)
	assumption.justify(AssumptionJustification.new(new_proof_box))
	new_proof_box.add_assumption(assumption)
	
	requirements.append(PROOF_STEP.new(
		goal,
		new_proof_box
	))


func _verify(proof_step):
	return (not (type in proof_step.get_proof_box().get_all_definitions())) \
	and ._verify(proof_step)


func _verify_expr_item(expr_item:ExprItem):
	return goal.compare(expr_item)


func get_justification_text():
	return "USING THIS EXISTENTIAL"
