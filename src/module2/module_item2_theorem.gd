extends ModuleItem2
class_name ModuleItem2Theorem

var goal : ExprItem
var context : SymmetryBox

func _init(context:SymmetryBox, statement:ExprItem, proof=null, version=0):
	goal = statement
	self.context = context
	self.proof_box = context.get_child_extended_with(
		[], [statement]
	)
	if proof is Dictionary:
		ProofStep.deserialize_proof(ProofStep, proof, context, version)

func get_as_assumption():
	return ModuleItem2Assumption.new(context, goal)

func serialise():
	var proof_step = ProofStep.new(Requirement.new(goal), context)
	return {
		kind="theorem",
		expr=goal.serialize(),
		proof=proof_step.serialize_proof()
	}

func get_goal() -> ExprItem:
	return goal

func get_requirement() -> Requirement:
	return Requirement.new(goal)

func get_context() -> SymmetryBox:
	return context
