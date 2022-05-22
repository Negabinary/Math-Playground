extends Node
class_name ExprItemParser2

var keywords = [
	"import", "define", "assume", "show", 
	"forall", "exists", "fun", "if", "then",
	"_import_", "_define_", "_assume_", "_show_", 
	"_forall_", "_exists_", "_fun_", "_if_", "_then_",
	".", ",", ":", "(", ")", "->", "_->_", "=", "as",
	"and", "or"
]

var tokens : Array
var proof_box : ParseBox

var error := false
var error_dict := {}
var result : ExprItem

var i := 0


static func err(token, string):
	return {error=true, error_type=string, token=token}


func _init(string:String, proof_box):
	self.tokens = Parser2.lex(string)
	self.proof_box = proof_box
	var result = eat_expr(proof_box)
	if result.error:
		error = true
		error_dict = result
	else:
		result = result.expr_item
	

func eat_name() -> Dictionary:
	if len(tokens) == i:
		 return err(tokens[i-1], "Expected name after this: ")
	elif tokens[i].contents in keywords:
		return err(tokens[i], "Unexpected keyword: ")
	else:
		i += 1
		return {error=false, name=tokens[i-1].contents}


func eat_expr(proof_box:ProofBox) -> Dictionary:
	match tokens[i].contents:
		"forall":
			i += 1
			var bindings_parse := eat_bindings(proof_box)
			if bindings_parse["error"]:
				return bindings_parse
			if tokens[i].contents != ".":
				return err(tokens[i-1], "Expected . after: ")
			i += 1
			var new_proof_box = ParseBox.new(proof_box, bindings_parse.types)
			var content_parse = eat_expr(new_proof_box)
			if content_parse["error"]:
				return content_parse
			var result:ExprItem = content_parse.expr_item
			for type in bindings_parse["types"]:
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
			i += 1
			var bindings_parse := eat_bindings(proof_box)
			if bindings_parse["error"]:
				return bindings_parse
			if tokens[i].contents != ".":
				return err(tokens[i-1], "Expected . after: ")
			var new_proof_box = ParseBox.new(proof_box, bindings_parse.types)
			i += 1
			var content_parse = eat_expr(new_proof_box)
			if content_parse["error"]:
				return content_parse
			var result:ExprItem = content_parse.expr_item
			for type in bindings_parse["types"]:
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
			i += 1
			var bindings_parse := eat_bindings(proof_box)
			if bindings_parse["error"]:
				return bindings_parse
			if tokens[i].contents != ".":
				return err(tokens[i-1], "Expected . after: ")
			i += 1
			var new_proof_box = ParseBox.new(proof_box, bindings_parse.types)
			var content_parse = eat_expr(new_proof_box)
			if content_parse["error"]:
				return content_parse
			var result:ExprItem = content_parse.expr_item
			for type in bindings_parse["types"]:
				if type in bindings_parse.tags:
					err(tokens[i-1], "Tagged lambda is not available yet.")
				result = ExprItem.new(
					GlobalTypes.LAMBDA,
					[ExprItem.new(type), result]
				)
			return {error=false, expr_item=result}
		"if":
			i += 1
			var lhs_parse := eat_expr(proof_box)
			if lhs_parse.error:
				return lhs_parse
			if tokens[i].contents != "then":
				return err(tokens[i-1], "Expected 'then' after: ")
			i += 1
			var rhs_parse := eat_expr(proof_box)
			if rhs_parse.error:
				return rhs_parse
			return {error=false, expr_item=ExprItem.new(
				GlobalTypes.IMPLIES,
				[lhs_parse.expr_item, rhs_parse.expr_item]
			)}
		_:
			var stuff_parse := eat_stuff(proof_box)
			if stuff_parse.error:
				return stuff_parse
			if len(tokens) == i:
				return {error=false, expr_item=stuff_parse.expr_item}
			if tokens[i].contents == ":":
				i += 1
				var tag_parse := eat_tag(proof_box)
				if tag_parse.error:
					return tag_parse
				return {error=false, expr_item=ExprItemTagHelper.tag_to_statement(tag_parse.tag, stuff_parse.expr_item)}
			if tokens[i].contents == "and":
				i += 1
				var stuff_parse_2 := eat_stuff(proof_box)
				if stuff_parse_2.error:
					return stuff_parse_2
				return {error=false, 
					expr_item = ExprItem.new(
						GlobalTypes.AND,
						[stuff_parse.expr_item, stuff_parse_2.expr_item]
					)
				}
			if tokens[i].contents == "or":
				i += 1
				var stuff_parse_2 := eat_stuff(proof_box)
				if stuff_parse_2.error:
					return stuff_parse_2
				return {error=false, 
					expr_item = ExprItem.new(
						GlobalTypes.OR,
						[stuff_parse.expr_item, stuff_parse_2.expr_item]
					)
				}
			if tokens[i].contents == "=":
				i += 1
				var stuff_parse_2 := eat_stuff(proof_box)
				if stuff_parse_2.error:
					return stuff_parse_2
				return {error=false, 
					expr_item = ExprItem.new(
						GlobalTypes.EQUALITY,
						[stuff_parse.expr_item, stuff_parse_2.expr_item]
					)
				}
			else:
				return {error=false, expr_item=stuff_parse.expr_item}


func eat_bindings(proof_box:ProofBox) -> Dictionary:
	var types := []
	var tags := {}
	while not i == len(tokens):
		if tokens[i].contents in keywords:
			break
		var name := eat_name()
		if name.error:
			return name
		var type := ExprItemType.new(name.name)
		types.append(type)
		if tokens[i].contents == ":":
			i += 1
			var tag_parse := eat_tag(proof_box)
			if tag_parse.error:
				return tag_parse
			tags[type] = tag_parse.tag
		if tokens[i].contents != ",":
			break
		else:
			i += 1
	return {error=false, types=types, tags=tags}


func eat_tag(proof_box:ParseBox) -> Dictionary:
	if tokens[i].contents == "forall":
		i += 1
		var bindings_parse := eat_bindings(proof_box)
		if bindings_parse["error"]:
			return bindings_parse
		var new_proof_box = ParseBox.new(proof_box, bindings_parse.types)
		var content_parse = eat_tag(new_proof_box)
		if content_parse["error"]:
			return content_parse
		var result:ExprItem = content_parse["tag"]
		for type in bindings_parse["types"]:
			if type in bindings_parse.tags:
				return err(tokens[i-1], "Generics can't be tagged")
			result = ExprItem.new(
				TagShorthand.T_GEN,
				[ExprItem.new(type), result]
			)
		return {error=false, tag=result}
	else:
		var stuff_parse = eat_tstuff(proof_box)
		if stuff_parse["error"]:
			return stuff_parse
		if len(tokens) == i:
			return {error=false, tag=stuff_parse.tag}
		if tokens[i].contents == "->":
			i += 1
			var stuff_2_parse = eat_tag(proof_box)
			if stuff_2_parse["error"]:
				return stuff_2_parse
			return {error=false, tag=ExprItem.new(
				TagShorthand.F_DEF,
				[stuff_parse.tag, stuff_2_parse.tag]
			)}
		else:
			return {error=false, tag=stuff_parse.tag}


func eat_stuff(proof_box:ParseBox) -> Dictionary:
	var expr_items := []
	var first := true
	while i != len(tokens):
		if tokens[i].contents == "(":
			i += 1
			var stuff_parse = eat_expr(proof_box)
			if stuff_parse.error:
				return stuff_parse
			expr_items.append(stuff_parse.expr_item)
			if i == len(tokens):
				return err(tokens[i-1], "Expected close brackets")
			while tokens[i].contents == ",":
				i += 1
				if first:
					return err(tokens[i], "Unexpected comma")
				var stuff_parse2 = eat_stuff(proof_box)
				if stuff_parse2.error:
					return stuff_parse2
				expr_items.append(stuff_parse2.expr_item)
				if i == len(tokens):
					return err(tokens[i-1], "Expected close brackets")
			if tokens[i].contents != ")":
				return err(tokens[i], "Expected close brackets")
			i += 1
		elif tokens[i].contents in keywords:
			break
		else:
			var type = proof_box.parse(tokens[i].contents)
			if type == null:
				return err(tokens[i], "token not found in context")
			expr_items.append(ExprItem.new(type))
			i += 1
		first = false
	if len(expr_items) == 0:
		return err(tokens[i-1], "Expected expression after")
	var result:ExprItem = expr_items.pop_front()
	for x in expr_items:
		result = result.apply(x)
	return {error=false, expr_item=result}


func eat_tstuff(proof_box:ParseBox) -> Dictionary:
	var expr_items := []
	var first := true
	while i != len(tokens):
		if tokens[i].contents == "(":
			i += 1
			var tstuff_parse = eat_tag(proof_box)
			if tstuff_parse.error:
				return tstuff_parse
			expr_items.append(tstuff_parse.tag)
			while tokens[i].contents == ",":
				i += 1
				if first:
					return err(tokens[i], "Unexpected comma")
				var tstuff_parse2 = eat_tstuff(proof_box)
				if tstuff_parse2.error:
					return tstuff_parse2
				expr_items.append(tstuff_parse2.tag)
			if tokens[i].contents != ")":
				return err(tokens[i], "Expected close brackets")
			i += 1
		elif tokens[i].contents == ")":
			return err(tokens[i], "Unexpected close brackets")
		elif tokens[i].contents in keywords:
			break
		else:
			var type = proof_box.parse(tokens[i].contents)
			if type == null:
				return err(tokens[i], "token not found in context")
			expr_items.append(ExprItem.new(type))
			i += 1
		first = false
	if len(expr_items) == 0:
		return err(tokens[i-1], "Expected tag after")
	var result:ExprItem = expr_items.pop_front()
	for x in expr_items:
		result.apply(x)
	return {error=false, tag=result}
