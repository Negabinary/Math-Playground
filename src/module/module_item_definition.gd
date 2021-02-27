extends ModuleItem
class_name ModuleItemDefinition

var type : ExprItemType
var alpha_tags : Array # [ExprItemType]
var tag : ExprItem
var as_assumption : ProofStep


func _init(module, tag=null, expr_item_type:=ExprItemType.new("???"), docstring:="").(module,docstring):
	self.type = expr_item_type
	self.tag = tag
	if tag != null:
		as_assumption = ProofStep.new(
				ExprItemTagHelper.tag_to_statement(tag, ExprItem.new(type)),
				module.get_proof_box(),
				AssumptionJustification.new(module.get_proof_box())
			)


func rename_type(new_name:String) -> void:
	type.rename(new_name)
	_sc()


func get_tag() -> ExprItem:
	return tag


func set_tag(tag:ExprItem) -> void:
	self.tag = tag
	_sc()


func get_definition() -> ExprItemType:
	return type


func delete():
	type.delete()
	.delete()


func get_as_assumption() -> ProofStep:
	if tag != null:
		return as_assumption
	return null


func has_as_assumption() -> bool:
	return tag != null
