extends Node
class_name ExprItemLambdaHelper


static func create_lambda(location:Locator, argument_locations:Array, argument_types:Array, argument_values:Array) -> ExprItem:
		var function_body := location.get_expr_item()
		
		var values_rev = []
		
		print(str("LL: ", location))
		print(location.get_indeces())
		print(str("AL: ", argument_locations))
		print(str("AT: ", argument_types))
		
		assert (argument_locations.size() == argument_types.size())
		for i in argument_locations.size():
			var type:ExprItemType = argument_types[i]
			var expr_item := ExprItem.new(type)
			for arg_loc in argument_locations[i]:
				var truncated_indeces:Array = arg_loc.get_indeces().duplicate()
				print(truncated_indeces)
				print(location.get_indeces())
				for idx in location.get_indeces():
					assert (idx == truncated_indeces[0])
					truncated_indeces.pop_front()
				print(truncated_indeces)
				print(str("BEFORE: ",function_body))
				function_body = function_body.replace_at(truncated_indeces, expr_item)
				print(str("AFTER: ",function_body))
			values_rev.push_front(argument_values[i])
		
		print(str("VR: ", values_rev))
		
		print(str("FB: ", function_body))
		
		var function := function_body
		for type in argument_types:
			function = ExprItem.new(
				GlobalTypes.LAMBDA,
				[ExprItem.new(type),function_body]
			)
		
		print(str("FN: ", function))
		
		var applied_function := ExprItem.new(
			GlobalTypes.LAMBDA,
			[function.get_child(0), function.get_child(1)] + values_rev
		)
		
		print(location.get_root())
		print(str("AF: ", applied_function))
		print(location.get_indeces())
		print(location.get_root().replace_at(location.get_indeces().duplicate(), applied_function))
		
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
