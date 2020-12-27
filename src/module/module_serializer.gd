class_name ModuleSerializer

static func serialize(module:MathModule) -> String:
	var string = ""
	
	string += "@M " + module.get_name() + "\n"
	
	string += "\n"
	
	for requirement in module.get_requirements():
		string += "@R " + requirement.get_name() + "\n"
	
	string += "\n"
	
	for item in module.get_items():
		string += _parse_item(item)
	
	return string


static func _parse_item(item:ModuleItem) -> String:
	if item is ModuleItemDefinition:
		return _parse_definition(item)
	elif item is ModuleItemTheorem:
		return _parse_theorem(item)
	else:
		assert (false) # Not yet implemented
		return ""


static func _parse_definition(item:ModuleItemDefinition) -> String:
	var item_tag:ExprItem = item.get_tag()
	if item_tag == null:
		return "@D " + item.get_definition().get_identifier() + "\n\n"
	else:
		var string = ""
		while (item_tag.get_type() == GlobalTypes.FORALL):
			string += "@A " + item_tag.get_child(0).get_type().get_identifier() + "\n"
			item_tag = item_tag.get_child(1)
		item_tag = item_tag.abandon_lowest(1)
		string += "@D " + item.get_definition().get_identifier() + " : " + item_tag.to_string() + "\n\n"
		return string


static func _parse_theorem(item:ModuleItemTheorem) -> String:
	if item.get_statement() == null:
		return ""
	else:
		return "@> " + item.get_statement().to_string() + "\n\n"
