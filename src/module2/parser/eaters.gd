class_name Eaters


const keywords = [
	"import", "define", "assume", "show", 
	"forall", "exists", "fun", "if", "then",
	"_import_", "_define_", "_assume_", "_show_", 
	"_forall_", "_exists_", "_fun_", "_if_", "_then_",
	".", ",", ":", "(", ")", "->", "_->_", "=", "as",
	"and", "or"
]


static func err(token, string):
	return {error=true, error_type=string, token=token}


static func eat_name(input_tape:ParserInputTape) -> Dictionary:
	if input_tape.done():
		 return err(input_tape.previous(), "Expected name after this: ")
	var token := input_tape.pop()
	if token.contents in keywords:
		return err(token, "Unexpected keyword: ")
	else:
		return {error=false, name=token.contents}


static func eat_bindings(input_tape:ParserInputTape, proof_box:AbstractParseBox) -> Dictionary:
	var types := [] # <ExprItemType>
	var tags := {} # <>
	while not input_tape.done():
		if input_tape.peek() in keywords:
			break
		var grouped_types := []
		while not input_tape.done():
			if input_tape.peek() in keywords:
				break
			var name := input_tape.pop().contents
			if name.count(".") > 0:
				return err(input_tape.previous(), "'.' is not allowed in new variable names.")
			var type := ExprItemType.new(name)
			grouped_types.append(type)
		types.append_array(grouped_types)
		if input_tape.try_eat(":"):
			var tag_parse := eat_tag(input_tape, proof_box)
			if tag_parse.error:
				return tag_parse
			for type in grouped_types:
				tags[type] = tag_parse.tag
		proof_box = ParseBox.new(proof_box, grouped_types)
		if not input_tape.try_eat(","):
			break
	if types.size() == 0:
		return err(input_tape.previous(), "Expected a binding after: ")
	return {error=false, types=types, tags=tags}


static func eat_expr(input_tape:ParserInputTape, proof_box:AbstractParseBox) -> Dictionary:
	if input_tape.done():
		return err(input_tape.previous(), "Unexpected end of expression")
	var token := input_tape.pop()
	match token.contents:
		"forall":
			var bindings_parse := eat_bindings(input_tape, proof_box)
			if bindings_parse["error"]:
				return bindings_parse
			if not input_tape.try_eat("."):
				return err(input_tape.previous(), "Expected '.' after: ")
			var new_parse_box = ParseBox.new(proof_box, bindings_parse.types)
			var content_parse = eat_expr(input_tape, new_parse_box)
			if content_parse["error"]:
				return content_parse
			var result:ExprItem = content_parse.expr_item
			var reversed_types_list:Array = bindings_parse["types"].duplicate()
			reversed_types_list.invert()
			for type in reversed_types_list:
				if type in bindings_parse.tags:
					result = ExprItem.new(GlobalTypes.IMPLIES,
						[
							ExprItemTagHelper.tag_to_statement(bindings_parse.tags[type],ExprItem.new(type)),
							result
						]
					)
				result = ExprItem.new(
					GlobalTypes.FORALL,
					[ExprItem.new(type), result]
				)
			return {error=false, expr_item=result}
		"exists":
			var bindings_parse := eat_bindings(input_tape, proof_box)
			if bindings_parse["error"]:
				return bindings_parse
			if not input_tape.try_eat("."):
				return err(input_tape.previous(), "Expected . after: ")
			var new_proof_box = ParseBox.new(proof_box, bindings_parse.types)
			var content_parse = eat_expr(input_tape, new_proof_box)
			if content_parse["error"]:
				return content_parse
			var result:ExprItem = content_parse.expr_item
			var reversed_types_list:Array = bindings_parse["types"].duplicate()
			reversed_types_list.invert()
			for type in reversed_types_list:
				if type in bindings_parse.tags:
					result = ExprItem.new(GlobalTypes.AND,
						[
							ExprItemTagHelper.tag_to_statement(bindings_parse.tags[type],ExprItem.new(type)),
							result
						]
					)
				result = ExprItem.new(
					GlobalTypes.EXISTS,
					[ExprItem.new(type), result]
				)
			return {error=false, expr_item=result}
		"fun":
			var bindings_parse := eat_bindings(input_tape, proof_box)
			if bindings_parse["error"]:
				return bindings_parse
			if not input_tape.try_eat("."):
				return err(input_tape.previous(), "Expected . after: ")
			var new_proof_box = ParseBox.new(proof_box, bindings_parse.types)
			var content_parse = eat_expr(input_tape, new_proof_box)
			if content_parse["error"]:
				return content_parse
			var result:ExprItem = content_parse.expr_item
			var reversed_types_list:Array = bindings_parse["types"].duplicate()
			reversed_types_list.invert()
			for type in reversed_types_list:
				if type in bindings_parse.tags:
					return err(input_tape.previous(), "Cannot use a tag in a lambda.")
				result = ExprItem.new(
					GlobalTypes.LAMBDA,
					[ExprItem.new(type), result]
				)
			return {error=false, expr_item=result}
		"if":
			var lhs_parse := eat_expr(input_tape, proof_box)
			if lhs_parse.error:
				return lhs_parse
			if not input_tape.try_eat("then"):
				return err(input_tape.previous(), "Expected 'then' after: ")
			var rhs_parse := eat_expr(input_tape, proof_box)
			if rhs_parse.error:
				return rhs_parse
			return {error=false, expr_item=ExprItem.new(
				GlobalTypes.IMPLIES,
				[lhs_parse.expr_item, rhs_parse.expr_item]
			)}
		_:
			input_tape.go_back()
			return eat_builtinfix(input_tape, proof_box)


static func reduce_builtinfix(ei_stack:Array, infix_stack:Array) -> void:
	var infix_type = infix_stack.pop_back()
	var expr_item_2 = ei_stack.pop_back()
	var expr_item_1 = ei_stack.pop_back()
	match infix_type.contents:
		":":
			ei_stack.push_back(
				{
					error=false, 
					expr_item=ExprItemTagHelper.tag_to_statement(
						expr_item_2.tag, expr_item_1.expr_item
					)
				}
			)
		"=":
			ei_stack.push_back(
				{
					error=false,
					expr_item=ExprItem.new(
						GlobalTypes.EQUALITY,
						[expr_item_1.expr_item, expr_item_2.expr_item]
					)
				}
			)
		"and":
			ei_stack.push_back(
				{
					error=false,
					expr_item=ExprItem.new(
						GlobalTypes.AND,
						[expr_item_1.expr_item, expr_item_2.expr_item]
					)
				}
			)
		"or":
			ei_stack.push_back(
				{
					error=false,
					expr_item=ExprItem.new(
						GlobalTypes.OR,
						[expr_item_1.expr_item, expr_item_2.expr_item]
					)
				}
			)


static func eat_builtinfix(input_tape:ParserInputTape, proof_box:AbstractParseBox) -> Dictionary:
	var initial_stuff := eat_stuff(input_tape, proof_box)
	if initial_stuff.error:
		return initial_stuff
	var ei_stack := [initial_stuff] #<Dictionary>
	var infix_stack := [] #<Token>
	while input_tape.peek() in [":", "=", "and", "or"]:
		var next := input_tape.pop()
		match next.contents:
			":":
				if not infix_stack.empty() and infix_stack.back().contents == ":":
					return err(input_tape.previous(), "Cannot tag a tagging. (Too many ':'s.)")
				var tstuff := eat_tag(input_tape, proof_box)
				if tstuff.error:
					return tstuff
				ei_stack.push_back(tstuff)
				infix_stack.push_back(next)
			"=":
				while not infix_stack.empty() and infix_stack.back().contents in [":", "="]:
					reduce_builtinfix(ei_stack, infix_stack)
				var stuff_2 := eat_stuff(input_tape, proof_box)
				if stuff_2.error:
					return stuff_2
				ei_stack.push_back(stuff_2)
				infix_stack.push_back(next)
			"and":
				while not infix_stack.empty() and infix_stack.back().contents in [":", "=", "and"]:
					reduce_builtinfix(ei_stack, infix_stack)
				var stuff_2 := eat_stuff(input_tape, proof_box)
				if stuff_2.error:
					return stuff_2
				ei_stack.push_back(stuff_2)
				infix_stack.push_back(next)
			"or":
				while not infix_stack.empty() and infix_stack.back().contents in [":", "=", "and", "or"]:
					reduce_builtinfix(ei_stack, infix_stack)
				var stuff_2 := eat_stuff(input_tape, proof_box)
				if stuff_2.error:
					return stuff_2
				ei_stack.push_back(stuff_2)
				infix_stack.push_back(next)
	while not infix_stack.empty() and infix_stack.back().contents in [":", "=", "and", "or"]:
		reduce_builtinfix(ei_stack, infix_stack)
	assert(ei_stack.size() == 1)
	assert(infix_stack.size() == 0)
	return ei_stack[0]


static func eat_tag(input_tape:ParserInputTape, proof_box:AbstractParseBox) -> Dictionary:
	if input_tape.done():
		return err(input_tape.previous(), "Expected tag after:")
	if input_tape.try_eat("forall"):
		var bindings_parse := eat_bindings(input_tape, proof_box)
		if bindings_parse["error"]:
			return bindings_parse
		if not input_tape.try_eat("."):
			return err(input_tape.previous(), "Expected . after: ")
		var new_proof_box := ParseBox.new(proof_box, bindings_parse.types)
		var content_parse := eat_tag(input_tape, new_proof_box)
		if content_parse["error"]:
			return content_parse
		var result:ExprItem = content_parse.tag
		for type in bindings_parse.types:
			if type in bindings_parse.tags:
				return err(input_tape.previous(), "Generics can't be tagged")
			result = ExprItem.new(
				TagShorthand.T_GEN,
				[ExprItem.new(type), result]
			)
		return {error=false, tag=result}
	else:
		var stuff_parse = eat_tstuff(input_tape, proof_box)
		if stuff_parse.error:
			return stuff_parse
		if input_tape.done():
			return {error=false, tag=stuff_parse.tag}
		if input_tape.try_eat("->"):
			var stuff_2_parse := eat_tag(input_tape, proof_box)
			if stuff_2_parse.error:
				return stuff_2_parse
			return {error=false, tag=ExprItem.new(
				TagShorthand.F_DEF,
				[stuff_parse.tag, stuff_2_parse.tag]
			)}
		else:
			return {error=false, tag=stuff_parse.tag}


static func eat_stuff(input_tape:ParserInputTape, proof_box:AbstractParseBox) -> Dictionary:
	var expr_items := []
	var first := true
	while not input_tape.done():
		if input_tape.try_eat("("):
			var stuff_parse = eat_expr(input_tape, proof_box)
			if stuff_parse.error:
				return stuff_parse
			expr_items.append(stuff_parse.expr_item)
			if input_tape.done():
				return err(input_tape.previous(), "Expected close brackets")
			while input_tape.try_eat(","):
				if first:
					return err(input_tape.pop(), "Unexpected comma")
				var stuff_parse2 := eat_expr(input_tape, proof_box)
				if stuff_parse2.error:
					return stuff_parse2
				expr_items.append(stuff_parse2.expr_item)
				if input_tape.done():
					return err(input_tape.previous(), "Expected close brackets")
			if not input_tape.try_eat(")"):
				return err(input_tape.previous(), "Expected close brackets:")
		elif input_tape.peek() in keywords:
			break
		else:
			var type := proof_box.parse_full(input_tape.pop().contents)
			if type == null:
				return err(input_tape.previous(), "token not found in context")
			expr_items.append(ExprItem.new(type))
		first = false
	if len(expr_items) == 0:
		return err(input_tape.previous(), "Expected expression after")
	var result:ExprItem = expr_items.pop_front()
	for x in expr_items:
		result = result.apply(x)
	return {error=false, expr_item=result}


static func eat_tstuff(input_tape:ParserInputTape, proof_box:AbstractParseBox) -> Dictionary:
	var expr_items := []
	var first := true
	while not input_tape.done():
		if input_tape.try_eat("("):
			var tstuff_parse := eat_tag(input_tape, proof_box)
			if tstuff_parse.error:
				return tstuff_parse
			expr_items.append(tstuff_parse.tag)
			if input_tape.done():
				return err(input_tape.previous(), "Expected close brackets")
			while input_tape.try_eat(","):
				if first:
					return err(input_tape.previous(), "Unexpected comma")
				var tstuff_parse2 = eat_tstuff(input_tape, proof_box)
				if tstuff_parse2.error:
					return tstuff_parse2
				expr_items.append(tstuff_parse2.tag)
				if input_tape.done():
					return err(input_tape.previous(), "Expected close brackets")
			if not input_tape.try_eat(")"):
				return err(input_tape.pop(), "Expected close brackets")
		elif input_tape.peek() in keywords:
			break
		else:
			var type = proof_box.parse_full(input_tape.pop().contents)
			if type == null:
				return err(input_tape.previous(), "token not found in context")
			expr_items.append(ExprItem.new(type))
		first = false
	if len(expr_items) == 0:
		return err(input_tape.previous(), "Expected tag after")
	var result:ExprItem = expr_items.pop_front()
	for x in expr_items:
		result = result.apply(x)
	return {error=false, tag=result}
