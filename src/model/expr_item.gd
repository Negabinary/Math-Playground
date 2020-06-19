extends Object
class_name ExprItem

var type : ExprItemType
var children : Array  		# of ExprItem

func _init(new_type:ExprItemType, new_children:=[]):
	type = new_type
	children = new_children


static func from_string(string:String, types:={}) -> ExprItem:
	types["=>"] = GlobalTypes.IMPLIES
	types["For all"] = GlobalTypes.FORALL
	var context_stack := [[]]
	var current_string := ""
	for i in range(string.length() - 1, -1, -1): # BACKWARDS
		var chr = string[i]
		if chr == ")":
			context_stack.push_front([])
		elif chr == "," or chr == "(":
			var current_children = context_stack.pop_front()
			types[current_string] = types.get(current_string, ExprItemType.new(current_string))
			context_stack[0].push_front(load("res://src/model/expr_item.gd").new(types[current_string], current_children))
			if chr == ",":
				context_stack.push_front([])
			current_string = ""
		else:
			current_string = chr + current_string
	var current_children = context_stack.pop_front()
	types[current_string] = types.get(current_string, ExprItemType.new(current_string))
	return load("res://src/model/expr_item.gd").new(types[current_string], current_children)


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


func _to_string() -> String:
	if children.size() == 0:
		return type.to_string()
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
