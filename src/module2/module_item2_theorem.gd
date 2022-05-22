extends ModuleItem2
class_name ModuleItem2Theorem

var requirement : Requirement
var context : ProofBox

func _init(context:ProofBox, statement:ExprItem, proof=null):
	requirement = Requirement.new(statement)
	self.context = context
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

func get_context() -> ProofBox:
	return context
