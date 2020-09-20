extends Node
class_name ExprItemBuilder

static func from_string(string:String, scope_stack:ScopeStack) -> ExprItem:
	var intermediate := _generate_intermediate(string)
	return _generate_expr_item(intermediate, scope_stack)
	

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


static func _generate_expr_item(intermediate:IntermediateExprItem, scope_stack:ScopeStack) -> ExprItem:
	if intermediate.token == GlobalTypes.FORALL.get_identifier():
		var new_types := deep_generate_types(intermediate.children[0])
		var new_type_dict := {}
		for new_type in new_types:
			new_type_dict[new_type.get_identifier()] = new_type
		var inner_scope := scope_stack.new_child_context(new_type_dict)
		var lhs = _generate_expr_item(intermediate.children[0], inner_scope)
		var rhs = _generate_expr_item(intermediate.children[1], inner_scope)
		return ExprItem.new(GlobalTypes.FORALL, [lhs, rhs])
	elif intermediate.token == GlobalTypes.EXISTS.get_identifier():
		var new_types := deep_generate_types(intermediate.children[0])
		var new_type_dict := {}
		for new_type in new_types:
			new_type_dict[new_type.get_identifier()] = new_type
		var inner_scope := scope_stack.new_child_context(new_type_dict)
		var lhs = _generate_expr_item(intermediate.children[0], inner_scope)
		var rhs = _generate_expr_item(intermediate.children[1], inner_scope)
		return ExprItem.new(GlobalTypes.FORALL, [lhs, rhs])
	else:
		print(intermediate.token)
		assert(scope_stack.get_from_scope(intermediate.token) != null)
		var type:ExprItemType = scope_stack.get_from_scope(intermediate.token)
		var new_chidlren := []
		for child in intermediate.children:
			new_chidlren.append(_generate_expr_item(child, scope_stack))
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
