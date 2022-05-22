extends ModuleItem2
class_name ModuleItem2Theorem

var requirement : Requirement

func _init(context:ProofBox, statement:ExprItem, proof=null):
	requirement = Requirement.new(statement)
	self.proof_box =  ProofBox.new(
		context, [], [statement]
	)

func serialise():
	return {
		kind="theorem",
		requirement=requirement.serialize()
	}

func get_requirement() -> Requirement:
	return requirement
