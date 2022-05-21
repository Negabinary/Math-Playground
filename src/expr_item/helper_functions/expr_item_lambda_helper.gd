extends Node
class_name ExprItemLambdaHelper

"""
function_body : ExprItem
argument_locations : Locator [where root = function_boxy] Array Array
argument_types : ExprItemType Array
argument_values : ExprItem Array
"""
static func create_lambda(function_body:ExprItem, argument_locations:Array, argument_types:Array, argument_values:Array) -> ExprItem:
	var values_rev = []
		
	assert (argument_locations.size() == argument_types.size())
	for i in argument_locations.size():
		var type:ExprItemType = argument_types[i]
		var expr_item := ExprItem.new(type)
		for arg_loc in argument_locations[i]:
			function_body = function_body.replace_at(arg_loc.get_indeces().duplicate(), expr_item)
		values_rev.push_front(argument_values[i])
	
	var function := function_body
	for type in argument_types:
		function = ExprItem.new(
			GlobalTypes.LAMBDA,
			[ExprItem.new(type),function_body]
		)
		
	var applied_function := ExprItem.new(
		GlobalTypes.LAMBDA,
		[function.get_child(0), function.get_child(1)] + values_rev
	)
	
	return applied_function


static func create_lambda_at(location:Locator, argument_locations:Array, argument_types:Array, argument_values:Array) -> ExprItem:
	var body = location.get_expr_item()
	var new_body = create_lambda(body, argument_locations, argument_types, argument_values)
	return location.get_root().replace_at(location.get_indeces(), new_body)


static func can_apply_lambda(expr_item:ExprItem):
	if expr_item.get_type() != GlobalTypes.LAMBDA:
		return false
	if expr_item.get_child_count() < 3:
		return false


static func apply_lambda(lambda:ExprItem):
	var children := lambda.get_children()
	var variable:ExprItem = children.pop_front()
	var body:ExprItem = children.pop_front()
	var value:ExprItem = children.pop_front()
	
	var variable_instances = Locator.new(body).find_all(variable)
	for variable_instance in variable_instances:
		body = body.replace_at(variable_instance.get_indeces(), value)
	for child in children:
		body = body.apply(child)
	return body


static func apply_lambda_at(location:Locator):
	var root := location.get_root()
	var lambda := location.get_expr_item()
	var body = apply_lambda(lambda)
	return root.replace_at(location.get_indeces(), body)
