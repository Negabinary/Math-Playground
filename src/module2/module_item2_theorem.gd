extends ModuleItem2
class_name ModuleItem2Theorem

var goal : ExprItem
var context : ProofBox

func _init(context:ProofBox, statement:ExprItem, proof=null):
	goal = statement
	self.context = context
	self.proof_box = ProofBox.new(
		context, [], [statement]
	)

func serialise():
	return {
		kind="theorem",
		expr=goal.serialize(),
		proof="proofs not serialisable yet..."
	}

func get_requirement() -> Requirement:
	return Requirement.new(goal)

func get_context() -> ProofBox:
	return context
