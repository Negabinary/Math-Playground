extends ModuleItem2
class_name ModuleItem2Definition

var definition : ExprItemType

func _init(context:ProofBox, definition:ExprItemType):
	proof_box = ProofBox.new(
		[definition], context
	)
	self.definition = definition

func get_definition() -> ExprItemType:
	return definition
