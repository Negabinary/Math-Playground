extends Justification
class_name InstantiateJustification


var new_type : ExprItemType # Store : Name
var old_type : ExprItemType
var existential : ExprItem
var goal : ExprItem


func _init(context:ProofBox, new_type_name:String, old_type:ExprItemType, existential:ExprItem, goal:ExprItem):
	self.new_type = ExprItemType.new(new_type_name)
	self.old_type = old_type
	self.existential = existential
	self.goal = goal
	
	requirements.append(PROOF_STEP.new(
		ExprItem.new(GlobalTypes.EXISTS, [ExprItem.new(old_type), existential]),
		context
	))
	
	var new_proof_box = ProofBox.new([new_type],context)
	var assumption = PROOF_STEP.new(existential.deep_replace_types({old_type:ExprItem.new(new_type)}), new_proof_box)
	assumption.justify(AssumptionJustification.new(new_proof_box))
	new_proof_box.add_assumption(assumption)
	
	requirements.append(PROOF_STEP.new(
		goal,
		new_proof_box
	))


func get_existential_requirement():
	return requirements[0]


func _verify(proof_step):
	return (not (old_type in proof_step.get_proof_box().get_all_definitions())) \
	and (not (new_type in proof_step.get_proof_box().get_all_definitions())) \
	and ._verify(proof_step)


func _verify_expr_item(expr_item:ExprItem):
	return goal.compare(expr_item)


func get_justification_text():
	return "USING THIS EXISTENTIAL"
