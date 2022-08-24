extends Object
class_name AbstractParseBox


signal added # (type:ExprItemType, new_name:String)
signal renamed # (type:ExprItemType, old_name:String, new_name:String)
signal removed # (type:ExprItemType, old_name:String)


var NORMAL_PARSE_BOX = load("res://src/proof_box/parse_box/parse_box.gd")


func serialise(expr_item:ExprItem) -> String:
	if expr_item.get_type().is_binder():
		var string = ""
		string += get_name_for(expr_item.get_type())
		for child_id in expr_item.get_child_count():
			if child_id == 0:
				string += "(" + expr_item.get_child(0).get_type().to_string() + ")"
			elif child_id == 1:
				var npb : AbstractParseBox = NORMAL_PARSE_BOX.new(self, [expr_item.get_child(0).get_type()])
				string += "(" + npb.serialise(expr_item.get_child(1)) + ")"
			else:
				string += "(" + serialise(expr_item.get_child(child_id)) + ")"
		return string
	else:
		var string = ""
		string += get_name_for(expr_item.get_type())
		for child in expr_item.get_children():
			string += "(" + serialise(child) + ")"
		return string


func printout(expr_item:ExprItem) -> String:
	var type = expr_item.get_type()
	var children = expr_item.get_children()
	
	if children.size() == 0:
		return get_name_for(type)
	elif type == GlobalTypes.IMPLIES and children.size() == 2:
		return (
			"if " 
			+ printout(children[0]) 
			+ " then " 
			+ printout(children[1])
		)
	elif type == GlobalTypes.FORALL and children.size() == 2:
		return (
			"forall " 
			+ children[0].get_type().get_identifier()
			+ ". " 
			+ NORMAL_PARSE_BOX.new(self, [children[0].get_type()]).printout(children[1])
		)
	elif type == GlobalTypes.EXISTS and children.size() == 2:
		return (
			"exists " 
			+ children[0].get_type().get_identifier()
			+ ". " 
			+ NORMAL_PARSE_BOX.new(self, [children[0].get_type()]).printout(children[1])
		)
	elif type == GlobalTypes.LAMBDA and children.size() == 2:
		return (
			"fun " 
			+ children[0].get_type().get_identifier()
			+ ". " 
			+ NORMAL_PARSE_BOX.new(self, [children[0].get_type()]).printout(children[1])
		)
	elif type == GlobalTypes.LAMBDA and children.size() > 2:
		var children_string:String = (
			"(fun " 
			+ printout(children[0]) 
			+ ". " 
			+ NORMAL_PARSE_BOX.new(self, [children[0].get_type()]).printout(children[1])
			+ ")("
		)
		for i in range(2, children.size() - 1):
			children_string += printout(children[i]) + ", "
		children_string += printout(children[-1]) + ")"
		return children_string
	elif type == GlobalTypes.AND and children.size() == 2:
		var children_string := ""
		if children[0].get_type() in [GlobalTypes.AND, GlobalTypes.OR]:
			children_string += "(" + printout(children[0]) + ")"
		else:
			children_string += printout(children[0])
		children_string += " and "
		if children[1].get_type() in [GlobalTypes.AND, GlobalTypes.OR]:
			children_string += "(" + printout(children[1]) + ")"
		else:
			children_string += printout(children[1])
		return children_string
	elif type == GlobalTypes.OR and children.size() == 2:
		var children_string := ""
		if children[0].get_type() in [GlobalTypes.OR]:
			children_string += "(" + printout(children[0]) + ")"
		else:
			children_string += printout(children[0])
		children_string += " or "
		if children[1].get_type() in [GlobalTypes.OR]:
			children_string += "(" + printout(children[1]) + ")"
		else:
			children_string += printout(children[1])
		return children_string
	elif type == GlobalTypes.EQUALITY and children.size() == 2:
		var children_string := ""
		if children[0].get_type() in [GlobalTypes.OR, GlobalTypes.AND, GlobalTypes.EQUALITY]:
			children_string += "(" + printout(children[0]) + ")"
		else:
			children_string += printout(children[0])
		children_string += " = "
		if children[1].get_type() in [GlobalTypes.OR, GlobalTypes.AND, GlobalTypes.EQUALITY]:
			children_string += "(" + printout(children[1]) + ")"
		else:
			children_string += printout(children[1])
		return children_string
	else:
		var children_string = ""
		for child in children:
			children_string += printout(child) + ", "
		return (
			get_name_for(type)
			+ "("
			+ children_string.left(children_string.length() - 2)
			+ ")"
		)


func parse_full(full_name:String) -> ExprItemType:
	var split := full_name.split(".",true)
	if split.size() == 1:
		return parse(full_name, "")
	else:
		var module := split[0]
		split.remove(0)
		var ident = split.join(".")
		if module == "":
			ident = "." + ident
		return parse(ident, module)
	


func parse(identifier:String, module:String) -> ExprItemType:
	assert(false) # abstract
	return null


func get_name_for(type:ExprItemType) -> String:
	assert(false) # abstract
	return ""


func get_all_types() -> TwoWayParseMap:
	assert(false) # abstract
	return TwoWayParseMap.new()


static func _get_module_and_overwrite(identifier:String) -> PoolStringArray:
	var result := identifier.split(".")
	result.remove(result.size()-1)
	return result


static func _get_module_name(identifier:String) -> String:
	var mod_and_over := _get_module_and_overwrite(identifier)
	while not mod_and_over.empty() and mod_and_over[-1] == "":
		mod_and_over.remove(mod_and_over.size()-1)
	return mod_and_over.join(".")


static func _get_definition_name(identifier:String) -> String:
	return identifier.split(".")[-1]


static func _get_overwrite_count(identifier:String) -> int:
	var count := 0
	for i in _get_module_and_overwrite(identifier):
		if i == "":
			count += 1
	return count
