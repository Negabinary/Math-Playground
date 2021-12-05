extends ModuleItem2
class_name ModuleItem2Theorem

var context : ProofBox
var assumption : ExprItem

func _init(context:ProofBox, statement:ExprItem):
	self.context = context
	proof_box = ProofBox.new(
		[], context, null, ""
	)
	proof_box.add_assumption_statement(statement)
	self.assumption = statement

func get_assumption() -> ExprItem:
	return assumption

func get_current_proof_box() -> ProofBox:
	return context
