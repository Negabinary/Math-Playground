extends Node
class_name ExprItemLambdaHelper


static func create_lambda(location:Locator, argument_locations:Array, argument_types:Array, argument_values:Array) -> ExprItem:
		var function_body := location.get_expr_item()
		
		var values_rev = []
		
		assert (argument_locations.size() == argument_types.size())
		for i in argument_locations.size():
			var type:ExprItemType = argument_types[i]
			var expr_item := ExprItem.new(type)
			for arg_loc in argument_locations[i]:
				var truncated_indeces:Array = arg_loc.get_indeces().duplicate()
				for idx in location.get_indeces():
					assert (idx == truncated_indeces[0])
					truncated_indeces.pop_front()
				function_body = function_body.replace_at(truncated_indeces, expr_item)
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
		
		return location.get_root().replace_at(location.get_indeces().duplicate(), applied_function)


static func apply_lambda(location:Locator):
	var root := location.get_root()
	var lambda := location.get_expr_item()
	var children := lambda.get_children()
	var variable:ExprItem = children.pop_front()
	var body:ExprItem = children.pop_front()
	var value:ExprItem = children.pop_front()
	
	var variable_instances = Locator.new(body).find_all(variable)
	for variable_instance in variable_instances:
		body = body.replace_at(variable_instance.get_indeces(), value)
	
	return root.replace_at(location.get_indeces(), body)
