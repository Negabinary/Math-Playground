extends ModuleItem2
class_name ModuleItem2Assumption

var assumption : ExprItem
var context : SymmetryBox

func _init(context:SymmetryBox, statement:ExprItem):
	proof_box = context.get_child_extended_with(
		[], [statement]
	)
	self.assumption = statement
	self.context = context

func get_assumption() -> ExprItem:
	return assumption

func serialise():
	return {kind="assumption", expr=context.get_parse_box().serialise(assumption)}
