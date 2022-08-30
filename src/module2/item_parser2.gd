extends Node
class_name ItemParser2

var proof_box : SymmetryBox

var error := false
var error_dict := {}
var result_items := []

var i := 0


func _init(tokens:Array, proof_box):
	self.proof_box = proof_box
	var input_tape = ParserInputTape.new(tokens)
	var result = eat_toplevel(input_tape)
	if result.error:
		error = true
		error_dict = result
	else:
		result_items = result.items


func eat_toplevel(input_tape:ParserInputTape):
	if input_tape.done():
		 return Eaters.err(input_tape.previous(), "Expected toplevel token.")
	match input_tape.pop().contents:
		"import":
			var name := Eaters.eat_name(input_tape)
			if name.error:
				return name
			var def_item := ModuleItem2Import.new(
				proof_box, name.name #, true # TODO
			)
			proof_box = def_item.get_next_proof_box()
			return {error=false, type="import", items=[def_item]}
		"define":
			var name = Eaters.eat_name(input_tape)
			if name.error:
				return name
			var type := ExprItemType.new(name.name)
			var name_item := ModuleItem2Definition.new(
				proof_box, type
			)
			proof_box = name_item.get_next_proof_box()
			if input_tape.done():
				return {error=false, type="define", items=[name_item]}
			elif input_tape.try_eat(":"):
				var tag_parse := Eaters.eat_tag(input_tape, proof_box.get_parse_box())
				if tag_parse.error:
					return tag_parse
				var def_item := ModuleItem2Assumption.new(
					proof_box, ExprItemTagHelper.tag_to_statement(tag_parse.tag, ExprItem.new(type))
				)
				proof_box = def_item.get_next_proof_box()
				return {error=false, type="define", items=[name_item, def_item]}
			else:
				var bindings_tags
				var bindings_types
				if not input_tape.try_eat("as"):
					var bindings_parse := Eaters.eat_bindings(input_tape, proof_box.get_parse_box())
					if bindings_parse.error:
						return bindings_parse
					if not input_tape.try_eat("as"):
						return Eaters.err(input_tape.previous(), "Expected token at end of definition:")
					bindings_tags = bindings_parse.tags
					bindings_types = bindings_parse.types
				else:
					bindings_tags = {}
					bindings_types = []
				var new_proof_box = ParseBox.new(proof_box.get_parse_box(), bindings_types)
				var expr_parse := Eaters.eat_expr(input_tape, new_proof_box)
				if expr_parse.error:
					return expr_parse
				var rhs : ExprItem = expr_parse.expr_item
				var lhs : ExprItem = ExprItem.new(type)
				for b_type in bindings_types:
					lhs = lhs.apply(ExprItem.new(b_type))
				var expr_item = ExprItem.new(
					GlobalTypes.EQUALITY,
					[lhs, rhs]
				)
				bindings_types.invert()
				for b_type in bindings_types:
					if b_type in bindings_tags:
						expr_item = ExprItem.new(
							GlobalTypes.IMPLIES,
							[
								ExprItemTagHelper.tag_to_statement(
									bindings_tags[b_type],
									ExprItem.new(b_type)
								),
								expr_item
							]
						)
				for b_type in bindings_types:
					expr_item = ExprItem.new(
						GlobalTypes.FORALL,
						[ExprItem.new(b_type), expr_item]
					)
				var def_item := ModuleItem2Assumption.new(proof_box, expr_item)
				proof_box = def_item.get_next_proof_box()
				return {error=false, type="define", items=[name_item, def_item]}
		"assume":
			var ei_parse := Eaters.eat_expr(input_tape, proof_box.get_parse_box())
			if ei_parse.error:
				return ei_parse
			var ei:ExprItem = ei_parse.expr_item
			var def_item := ModuleItem2Assumption.new(proof_box, ei)
			proof_box = def_item.get_next_proof_box()
			return {error=false, type="define", items=[def_item]}
		"show":
			i += 1
			var ei_parse := Eaters.eat_expr(input_tape, proof_box.get_parse_box())
			if ei_parse.error:
				return ei_parse
			var ei:ExprItem = ei_parse.expr_item
			var def_item := ModuleItem2Theorem.new(proof_box, ei)
			proof_box = def_item.get_next_proof_box()
			return {error=false, type="define", items=[def_item]}
		_:
			return {
				error=true, 
				error_type="Expected toplevel command, instead found: ", 
				token=input_tape.previous()
			}
