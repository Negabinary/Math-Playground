extends Justification
class_name InstantiateJustification


var new_type : ExprItemType # Store : Name
var old_type : ExprItemType
var existential : ExprItem
var goal : ExprItem


func _get_reqs(context:ProofBox, new_type_name:String, old_type:ExprItemType, existential:ExprItem, goal:ExprItem) -> Array:
	var reqs := []
	reqs.append(Requirement.new(
		context,
		ExprItem.new(GlobalTypes.EXISTS, [ExprItem.new(old_type), existential])
	))
	
	self.new_type = ExprItemType.new(new_type_name)
	
	var new_proof_box = ProofBox.new(context, [new_type])
	var assumption = PROOF_STEP.new(existential.deep_replace_types({old_type:ExprItem.new(new_type)}), new_proof_box)
	assumption.justify(AssumptionJustification.new())
	new_proof_box.add_assumption(assumption)
	
	reqs.append(Requirement.new(
		new_proof_box,
		goal
	))
	return reqs


func _init(context:ProofBox, new_type_name:String, old_type:ExprItemType, existential:ExprItem, goal:ExprItem).(
		_get_reqs(context, new_type_name, old_type, existential, goal)
	):
	self.old_type = old_type
	self.existential = existential
	self.goal = goal


func get_existential_requirement():
	return requirements[0]


func _verify(proof_step):
	return (not (proof_step.get_proof_box().is_defined(old_type))) \
	and (not (proof_step.get_proof_box().is_defined(new_type))) \
	and ._verify(proof_step)


func _verify_expr_item(expr_item:ExprItem):
	return goal.compare(expr_item)


func get_justification_text():
	return "USING THIS EXISTENTIAL"
