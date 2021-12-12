extends ModuleItem2
class_name ModuleItem2Theorem

var context : ProofBox
var ps : ProofStep

func _init(context:ProofBox, statement:ExprItem, proof=null):
	self.context = context
	self.ps = ProofStep.new(statement, context)
	proof_box = ProofBox.new(
		[], context, null, ""
	)
	proof_box.add_assumption_statement(statement)

func get_current_proof_box() -> ProofBox:
	return context

func serialise():
	return {
		kind="theorem", 
		expr=ps.get_expr_item().serialize(), 
		proof=ps.serialise()
	}

func get_ps():
	return ps
