extends Node
class_name ExprItemBuilder

static func from_string(string:String, proof_box:ProofBox) -> ExprItem:
	var intermediate := _generate_intermediate(string)
	return _generate_expr_item(intermediate, proof_box)
	

static func _generate_intermediate(string:String) -> IntermediateExprItem:
	var context_stack := [[]]
	var current_string := ""
	for i in range(string.length() - 1, -1 , -1):
		var chr = string[i]
		if chr == ")":
			context_stack.push_front([])
		elif chr == "," or chr == "(":
			var current_children = context_stack.pop_front()
			context_stack[0].push_front(IntermediateExprItem.new(current_string, current_children))
			if chr == ",":
				context_stack.push_front([])
			current_string = ""
		else:
			current_string = chr + current_string
	var current_children = context_stack.pop_front()
	return IntermediateExprItem.new(current_string, current_children)


static func _generate_expr_item(intermediate:IntermediateExprItem, proof_box:ProofBox) -> ExprItem:
	assert(proof_box.parse(intermediate.token) != null)
	var type:ExprItemType = proof_box.parse(intermediate.token)
	var inner_proof_box
	if type.get_binder_type() != ExprItemType.BINDER.NOT_BINDER:
		inner_proof_box = ProofBox.new(deep_generate_types(intermediate.children[0]), proof_box)
	var new_chidlren := []
	for child in intermediate.children:
		match type.get_binder_type():
			ExprItemType.BINDER.NOT_BINDER:
				new_chidlren.append(_generate_expr_item(child, proof_box))
			ExprItemType.BINDER.BINDER:
				if intermediate.children.find(child) in [0,1]:
					new_chidlren.append(_generate_expr_item(child, inner_proof_box))
				else:
					new_chidlren.append(_generate_expr_item(child, proof_box))
	return ExprItem.new(type, new_chidlren)

static func deep_generate_types(intermediate:IntermediateExprItem, new_types=[]) -> Array:
	new_types.append(ExprItemType.new(intermediate.token))
	for child in intermediate.children:
		deep_generate_types(child, new_types)
	return new_types


class IntermediateExprItem:
	var token : String
	var children : Array # <IntermediateExprItem>
	
	func _init(new_token, new_children):
		token = new_token
		children = new_children
