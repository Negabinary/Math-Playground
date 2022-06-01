extends Object
class_name ExprItem

var type : ExprItemType
var children : Array  		# of ExprItem
var string : String
var all_types = null

func _init(new_type:ExprItemType, new_children:=[]):
	type = new_type
	children = new_children
	if GlobalTypes:
		string = to_string()

# GETTERS ========================================

func get_type() -> ExprItemType:
	return type


func get_child_count() -> int:
	return children.size()


func get_child(idx:int) -> ExprItem:
	return children[idx]


func get_children() -> Array:
	return children.duplicate()


func get_all_types() -> Dictionary:
	if all_types == null:
		all_types = {type:1}
		for child in children:
			var child_types:Dictionary = child.get_all_types()
			for k in child_types:
				all_types[k] = all_types.get(k, 0) + child_types[k]
	return all_types


# CHECKS =========================================

func compare(other:ExprItem, conversion:={}) -> bool:
	if type != other.type:
		return conversion.get(type) == other.type
	elif children.size() != other.children.size():
		return false
	elif type.get_binder_type() == ExprItemType.BINDER.BINDER:
		var from_type:ExprItemType = children[0].get_type()
		var to_type:ExprItemType = other.children[0].get_type()
		var new_conversion = conversion.duplicate()
		new_conversion[from_type] = to_type
		if !children[1].compare(other.children[1], new_conversion):
			return false
		for child_id in range(2,children.size()):
			if !children[child_id].compare(other.children[child_id], conversion):
				return false
		return true
	else:
		for child_id in children.size():
			if !children[child_id].compare(other.children[child_id], conversion):
				return false
		return true

# TODO: Check Semantics of this - could be wrong
func is_superset(other:ExprItem, matching:={}, conversion:={}) -> bool:
	if type == other.type and get_child_count() == other.get_child_count():
		if type.get_binder_type() == ExprItemType.BINDER.BINDER:
			var from_type:ExprItemType = children[0].get_type()
			var to_type:ExprItemType = other.children[0].get_type()
			var new_conversion = conversion.duplicate()
			if !children[1].is_superset(other.children[1], matching, new_conversion):
				return false
			for child_id in range(2,children.size()):
				if !children[child_id].is_superset(other.children[child_id], matching, conversion):
					return false
			return true
		else:
			for i in get_child_count():
				if not get_child(i).is_superset(other.get_child(i), matching):
					return false
			return true
	elif matching.has(type):
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
	else:
		return false


# OPERATIONS =====================================

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

func replace_at(indeces:Array, drop:int, with:ExprItem) -> ExprItem:
	indeces = indeces.duplicate()
	if indeces == []:
		var new_expr_item := with
		for i in range(get_child_count() - drop, get_child_count()):
			new_expr_item = new_expr_item.apply(get_child(i))
		return new_expr_item
	else:
		var new_children = []
		var j = indeces.pop_front()
		for i in get_child_count():
			if i == j:
				new_children.append(get_child(i).replace_at(indeces, drop, with))
			else:
				new_children.append(get_child(i))
		return get_script().new(type, new_children)


func negate() -> ExprItem:
	if get_type() == GlobalTypes.NOT:
		return get_child(0)
	else:
		return get_script().new(GlobalTypes.NOT, [self])


func apply(x:ExprItem):
	return get_script().new(
		get_type(),
		get_children() + [x]
	)


func abandon_lowest(count:int) -> ExprItem:
	assert (count <= children.size())
	var new_children = []
	for i in children.size() - count:
		new_children.append(children[i])
	return get_script().new(type, new_children)


# SERIALIZATION =====================================


func get_unique_name(indeces=[]) -> String:
	var string = ""
	string += str(type.get_uid())
	if type in indeces:
		return "#" + str(indeces.find(type))
	if type.is_binder():
		indeces.push_front(children[0].get_type())
	for child in children:
		string += "(" + child.get_unique_name(indeces) + ")"
	if type.is_binder():
		indeces.pop_front()
	return string


func serialize() -> String:
	var string = ""
	string += type.to_string()
	for child in children:
		string += "(" + child.serialize() + ")"
	return string


func _to_string() -> String:
	if children.size() == 0:
		return type.to_string()
	elif type == GlobalTypes.IMPLIES and children.size() == 2:
		return (
			"if " 
			+ children[0].to_string() 
			+ " then " 
			+ children[1].to_string()
		)
	elif type == GlobalTypes.FORALL and children.size() == 2:
		return (
			"forall " 
			+ children[0].to_string() 
			+ ". " 
			+ children[1].to_string()
		)
	elif type == GlobalTypes.EXISTS and children.size() == 2:
		return (
			"exists " 
			+ children[0].to_string() 
			+ ". " 
			+ children[1].to_string()
		)
	elif type == GlobalTypes.LAMBDA and children.size() == 2:
		return (
			"fun " 
			+ children[0].to_string() 
			+ ". " 
			+ children[1].to_string()
		)
	elif type == GlobalTypes.LAMBDA and children.size() > 2:
		var children_string:String = (
			"(fun " 
			+ children[0].to_string() 
			+ ". " 
			+ children[1].to_string()
			+ ")("
		)
		for i in range(2, children.size() - 1):
			children_string += children[i].to_string() + ", "
		children_string += children[-1].to_string() + ")"
		return children_string
	elif type == GlobalTypes.AND and children.size() == 2:
		var children_string := ""
		if children[0].get_type() in [GlobalTypes.AND, GlobalTypes.OR]:
			children_string += "(" + children[0].to_string() + ")"
		else:
			children_string += children[0].to_string()
		children_string += " and "
		if children[1].get_type() in [GlobalTypes.AND, GlobalTypes.OR]:
			children_string += "(" + children[1].to_string() + ")"
		else:
			children_string += children[1].to_string()
		return children_string
	elif type == GlobalTypes.OR and children.size() == 2:
		var children_string := ""
		if children[0].get_type() in [GlobalTypes.OR]:
			children_string += "(" + children[0].to_string() + ")"
		else:
			children_string += children[0].to_string()
		children_string += " or "
		if children[1].get_type() in [GlobalTypes.OR]:
			children_string += "(" + children[1].to_string() + ")"
		else:
			children_string += children[1].to_string()
		return children_string
	elif type == GlobalTypes.EQUALITY and children.size() == 2:
		var children_string := ""
		if children[0].get_type() in [GlobalTypes.OR, GlobalTypes.AND, GlobalTypes.EQUALITY]:
			children_string += "(" + children[0].to_string() + ")"
		else:
			children_string += children[0].to_string()
		children_string += " = "
		if children[1].get_type() in [GlobalTypes.OR, GlobalTypes.AND, GlobalTypes.EQUALITY]:
			children_string += "(" + children[1].to_string() + ")"
		else:
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
