class_name Provable

var expr_item : ExprItem
var justification : Justification = null
var children := []


func _init(expr_item:ExprItem, justification = null, children := []):
	self.expr_item = expr_item
	self.justification = justification
	self.children = children


func justify(justification:Justification):
	self.justification = justification
	var reqs = justification.get_requirements_for(expr_item)
	for r in reqs:
		children.append(get_script().new(r.get_goal()))


func get_children():
	return children


func get_child(i:int):
	return children[i]


func get_child_count() -> int:
	return len(children)


func get_expr_item() -> ExprItem:
	return expr_item


func apply_proof(context:SymmetryBox):
	if justification:
		context.get_justification_box().set_justification(expr_item, justification)
		for child in children:
			child.apply_proof(context)


func deep_replace_types(matching:Dictionary) -> Provable:
	var new_children = []
	for child in children:
		new_children.append(child.deep_replace_types(matching))
	return get_script().new(
		expr_item.deep_replace_types(matching),
		justification.deep_replace_types(matching) if justification else null,
		new_children
	)
