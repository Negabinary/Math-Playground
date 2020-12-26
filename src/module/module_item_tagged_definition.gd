extends ModuleItemDefinition
class_name ModuleItemTaggedDefintion

var tag : ExprItem

func _init(module, tag, expr_item_type:=ExprItemType.new("???"), docstring:="").(module, expr_item_type, docstring):
	self.tag = tag

func get_as_assumption():
	var proof_step = ProofStep.new(
		ExprItem.new(
			tag.get_type(),
			tag.get_children() + [ExprItem.new(type)]
		),
		module
	)
	proof_step.justify_with_module_axiom(module)
	return proof_step
