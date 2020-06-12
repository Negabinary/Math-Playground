extends Label

func update_definitions(definitions:Array): # Array<ExprItemType>
	var total_string = ""
	for definition in definitions:
		total_string += definition.to_string() + "; "
	text = total_string.left(total_string.length() - 2)
