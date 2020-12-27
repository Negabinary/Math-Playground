extends ModuleItem
class_name ModuleItemDefinition

var type : ExprItemType
var tag : ExprItem


func _init(module, tag=null, expr_item_type:=ExprItemType.new("???"), docstring:="").(module,docstring):
	self.type = expr_item_type
	self.tag = tag


func rename_type(new_name:String) -> void:
	type.rename(new_name)


func get_tag() -> ExprItem:
	return tag


func set_tag(tag:ExprItem) -> void:
	self.tag = tag


func get_definition() -> ExprItemType:
	return type


func delete():
	type.delete()
	.delete()


func get_as_assumption() -> ProofStep:
	if tag != null:
		var proof_step = ProofStep.new(
			ExprItem.new(
				tag.get_type(),
				tag.get_children() + [ExprItem.new(type)]
			),
			module
		)
		proof_step.justify_with_module_axiom(module)
		return proof_step
	return null
