extends ModuleItem2
class_name ModuleItem2Assumption

var assumption : ExprItem

func _init(context:ProofBox, statement:ExprItem):
	proof_box = context.get_child_extended_with(
		[], [statement]
	)
	self.assumption = statement

func get_assumption() -> ExprItem:
	return assumption

func serialise():
	return {kind="assumption", expr=assumption.serialize()}
