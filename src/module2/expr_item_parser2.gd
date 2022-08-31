class_name ExprItemParser2

var proof_box : AbstractParseBox

var error := false
var error_dict := {}
var result : ExprItem


static func err(token, string):
	return {error=true, error_type=string, token=token}


func _init(string:String, proof_box):
	self.proof_box = proof_box
	var input_tape = ParserInputTape.new(Parser2.lex(string))
	if input_tape.done():
		error = true
		error_dict = err(null, "Empty expression")
		return
	var result = Eaters.eat_expr(input_tape, proof_box)
	if result.error:
		error = true
		error_dict = result
	else:
		self.result = result.expr_item
