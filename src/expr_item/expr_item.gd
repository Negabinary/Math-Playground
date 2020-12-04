extends Object
class_name ExprItem

var type : ExprItemType
var children : Array  		# of ExprItem
var string : String
var all_types = null

func _init(new_type:ExprItemType, new_children:=[]):
	type = new_type
	children = new_children
	#string = to_string()


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
			assert(false)
			return get_script().new(types[type])
		elif types[type] is String:
			return get_script().new(new_type, new_children)
		else:
			new_type = types[type].get_type()
			new_children = types[type].get_children() + new_children
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


func get_children() -> Array:
	return children.duplicate()


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
	if matching.has(type):
		if get_child_count() > other.get_child_count():
			return false
		elif matching[type] is String:
			matching[type] = other.abandon_lowest(get_child_count())
			for i in get_child_count():
				if not get_child(i).is_superset(other.get_child(other.get_child_count() - get_child_count() + i), matching):
					return false
			return true
		else:
			var expected_other:ExprItem = get_script().new(matching[type].get_type(), matching[type].get_children() + get_children())
			if expected_other.is_superset(other, matching):
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
		) #+ str(get_all_types().keys())


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


func get_all_types() -> Dictionary:
	if all_types == null:
		all_types = {type:1}
		for child in children:
			for k in child.get_all_types():
				all_types[k] = all_types.get(k, 0) + 1
	return all_types
