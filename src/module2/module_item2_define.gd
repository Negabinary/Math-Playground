extends ModuleItem2
class_name ModuleItem2Definition

var definition : ExprItemType

func _init(context:SymmetryBox, definition:ExprItemType):
	proof_box = context.get_child_extended_with(
		[definition]
	)
	self.definition = definition

func get_definition() -> ExprItemType:
	return definition

func serialise():
	return {kind="definition", type=definition.to_string()}
