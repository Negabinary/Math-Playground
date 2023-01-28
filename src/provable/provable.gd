class_name Provable

var expr_item : ExprItem
var justification : Justification = null
var children := []

func _init(expr_item:ExprItem):
	self.expr_item = expr_item


func justify(justification:Justification):
	self.justification = justification
	var reqs = justification.get_requirements_for(expr_item)
	for r in reqs:
		children.append(get_script().new(r.get_goal()))


func get_children():
	return children


func get_child(i:int):
	return children[i]


func get_expr_item() -> ExprItem:
	return expr_item


func apply_proof(context):
	if justification:
		context.get_justification_box().set_justification(expr_item, justification)
		for child in children:
			child.apply_proof()
