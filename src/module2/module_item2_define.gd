extends ModuleItem2
class_name ModuleItem2Definition

var definition : ExprItemType

func _init(context:ProofBox, definition:ExprItemType):
	proof_box = ProofBox.new(
		context,
		[definition]
	)
	self.definition = definition

func get_definition() -> ExprItemType:
	return definition

func serialise():
	return {kind="definition", type=definition.to_string()}
