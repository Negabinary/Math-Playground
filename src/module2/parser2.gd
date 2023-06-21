class_name Parser2

static func lex(string:String) -> Array:
	var start_word := 0
	var cuml_word := ""
	var result := []
	for i in len(string):
		var c := string[i]
		if c in [" ","\n","\t",""]:
			if cuml_word != "":
				if cuml_word != ".":
					if cuml_word.ends_with("."):
						cuml_word = cuml_word.left(len(cuml_word) - 1)
						result.append(Token2.new(start_word, i, cuml_word))
						cuml_word = "."
						start_word = i - 2
				result.append(Token2.new(start_word, i, cuml_word))
				cuml_word = ""
			start_word = i
		elif c in [":", "(", ")", ","]:
			if cuml_word != "":
				result.append(Token2.new(start_word, i, cuml_word))
				cuml_word = ""
			result.append(Token2.new(i, i+1, c))
			start_word = i
		else:
			cuml_word += c
	if cuml_word != "":
		result.append(Token2.new(start_word, len(string), cuml_word))
		cuml_word = ""
	return result


static func split_toplevel(token_array) -> Array:
	var cuml_statement := []
	var result := []
	for token in token_array:
		if token.contents in ["import","define","assume", "show", "implement"]:
			if len(cuml_statement) > 0:
				result.append(cuml_statement)
				cuml_statement = []
		cuml_statement.append(token)
	if len(cuml_statement) > 0:
		result.append(cuml_statement)
		cuml_statement = []
	return result


static func create_items(proof_box:SymmetryBox, string:String) -> Dictionary:
	var tokens := lex(string)
	var tokenses := split_toplevel(tokens)
	var items := []
	var current_pb := proof_box
	for item_tokens in tokenses:
		var item_parser := ItemParser2.new(item_tokens, current_pb)
		if item_parser.error:
			return item_parser.error_dict
		items += item_parser.result_items
		current_pb = item_parser.proof_box
	return {error=false, items=items, proof_box=current_pb}
