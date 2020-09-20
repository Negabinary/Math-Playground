extends Object
class_name ExprItem

var type : ExprItemType
var children : Array  		# of ExprItem

func _init(new_type:ExprItemType, new_children:=[]):
	type = new_type
	children = new_children


static func from_string(string:String, types:={}) -> ExprItem:
	for global_type in GlobalTypes.get_map():
		types[global_type] = GlobalTypes.get_map()[global_type]
	var context_stack := [[]]
	var current_string := ""
	for i in range(string.length() - 1, -1, -1): # BACKWARDS
		var chr = string[i]
		if chr == ")":
			context_stack.push_front([])
		elif chr == "," or chr == "(":
			var current_children = context_stack.pop_front()
			types[current_string] = types.get(current_string, ExprItemType.new(current_string))
			context_stack[0].push_front(load("res://src/expr_item/expr_item.gd").new(types[current_string], current_children))
			if chr == ",":
				context_stack.push_front([])
			current_string = ""
		else:
			current_string = chr + current_string
	var current_children = context_stack.pop_front()
	types[current_string] = types.get(current_string, ExprItemType.new(current_string))
	return load("res://src/expr_item/expr_item.gd").new(types[current_string], current_children)


func deep_replace_types(types:Dictionary) -> ExprItem: #<ExprItemType, ExprItem>
	var new_children = []
	for child in children:
		new_children.append(child.deep_replace_types(types))
	var new_type = type
	if type in types:
		if types[type] is ExprItemType:
			return get_script().new(types[type])
		else:
			return types[type]
	return get_script().new(new_type, new_children)


func replace_at(indeces:Array, with:ExprItem) -> ExprItem:
	if indeces == []:
		return with
	else:
		var new_children = []
		var j = indeces.pop_front()
		for i in get_child_count():
			if i == j:
				new_children.append(get_child(i).replace_at(indeces, with))
			else:
				new_children.append(get_child(i))
		return get_script().new(type, new_children)


func negate() -> ExprItem:
	if get_type() == GlobalTypes.NOT:
		return get_child(0)
	else:
		return get_script().new(GlobalTypes.NOT, [self])


func get_type() -> ExprItemType:
	return type


func get_child_count() -> int:
	return children.size()


func get_child(idx:int) -> ExprItem:
	return children[idx]


func abandon_lowest(count:int) -> ExprItem:
	assert (count <= children.size())
	var new_children = []
	for i in children.size() - count:
		new_children.append(children[i])
	return get_script().new(type, new_children)


func compare(other:ExprItem) -> bool:
	if type != other.type:
		return false
	elif children.size() != other.children.size():
		return false
	else:
		for child_id in children.size():
			if !children[child_id].compare(other.children[child_id]):
				return false
		return true


func is_superset(other:ExprItem, matching:={}) -> bool:
	if type == GlobalTypes.FORALL:
		matching[get_child(0).get_type()] = "*"
		return get_child(1).is_superset(other, matching)
	elif matching.has(type):
		if matching[type] == "*":
			matching[type] = other
			return true
		elif matching[type].compare(other):
			return true
		else:
			return false
	elif type == other.type and get_child_count() == other.get_child_count():
		for i in get_child_count():
			if not get_child(i).is_superset(other.get_child(i), matching):
				return false
		return true
	else:
		return false


func _to_string() -> String:
	if children.size() == 0:
		return type.to_string()
	elif type == GlobalTypes.IMPLIES:
		var children_string = ""
		if children[0].get_type() == GlobalTypes.IMPLIES:
			children_string += "(" + children[0].to_string() + ")"
		else:
			children_string += children[0].to_string()
		children_string += " => "
		children_string += children[1].to_string()
		return children_string
	else:
		var children_string = ""
		for child in children:
			children_string += child.to_string() + ", "
		return (
			type.to_string() 
			+ "("
			+ children_string.left(children_string.length() - 2)
			+ ")"
		)


func get_postorder_rect_list(font:Font, offset, list:=[], string:=[""]):
	var start = font.get_string_size(string[0]).x
	
	if children.size() == 0:
		string[0] += type.to_string()
	elif type == GlobalTypes.IMPLIES:
		if children[0].get_type() == GlobalTypes.IMPLIES:
			string[0] += "("
			children[0].get_postorder_rect_list(font, offset, list, string)
			string[0] += ")"
		else:
			children[0].get_postorder_rect_list(font, offset, list, string)
		string[0] += " => "
		children[1].get_postorder_rect_list(font, offset, list, string)
	else:
		string[0] += type.to_string()
		string[0] += "("
		for child in children:
			child.get_postorder_rect_list(font, offset, list, string)
			string[0] += ", "
		string[0] = string[0].left(string[0].length() - 2)
		string[0] += ")"
	
	list.append(Rect2(
		offset+start, 0,
		font.get_string_size(string[0]).x - start,
		font.get_string_size(string[0]).y
	))
	
	return list
