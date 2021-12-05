extends ModuleItem2
class_name ModuleItem2Assumption

var assumption : ExprItem

func _init(context:ProofBox, statement:ExprItem):
	proof_box = ProofBox.new(
		[], context, null, "", [statement]
	)
	self.assumption = statement

func get_assumption() -> ExprItem:
	return assumption
