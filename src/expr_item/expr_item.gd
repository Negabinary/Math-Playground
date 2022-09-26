class_name ExprItem

var type : ExprItemType
var children : Array  		# of ExprItem
var string : String


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


var all_types = null

func get_all_types() -> Dictionary:
	if get_type().get_uid() == 207:
			print("HERE!")
	if all_types == null:
		all_types = {type:1}
		if type.is_binder():
			var r_type = get_child(0).get_type()
			var from = get_child(1).get_all_types().duplicate()
			from.erase(r_type)
			for k in from:
				all_types[k] = all_types.get(k, 0) + from[k]
			for cid in range(2,get_child_count()):
				var child_types:Dictionary = get_child(cid).get_all_types()
				for k in child_types:
					all_types[k] = all_types.get(k, 0) + child_types[k]
		else:
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


func _is_application() -> bool:
	return (
		(type.get_binder_type() == ExprItemType.BINDER.BINDER and get_child_count() > 2)
		or
		((type.get_binder_type() != ExprItemType.BINDER.BINDER) and get_child_count() > 0)
	)


func is_superset(other:ExprItem, matching:={}) -> bool:
	# Case Application
	if _is_application():
		if not other._is_application():
			return false
		if not abandon_lowest(1).is_superset(other.abandon_lowest(1), matching):
			return false
		return get_child(get_child_count()-1).is_superset(
			other.get_child(other.get_child_count()-1), matching)
	elif type.get_binder_type() == ExprItemType.BINDER.BINDER:
		if not other.get_type() == type:
			return false
		var from_type:ExprItemType = children[0].get_type()
		var to_type:ExprItemType = other.children[0].get_type()
		var replaced_version = get_child(1).deep_replace_types({from_type:get_script().new(to_type)})
		return replaced_version.is_superset(
			other.get_child(1), matching
		)
	elif type in matching:
		assert(get_child_count() == 0)
		if matching[type] is String:
			matching[type] = other
			return true
		else:
			return matching[type].compare(other)
	else:
		assert(get_child_count() == 0)
		return type == other.type


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
	if type in indeces:
		string += "#" + str(indeces.find(type))
	else:
		string += str(type.get_uid())
	if type.is_binder():
		indeces.push_front(children[0].get_type())
	for child in children:
		string += "(" + child.get_unique_name(indeces) + ")"
	if type.is_binder():
		indeces.pop_front()
	return string


func _to_string() -> String:
	if children.size() == 0:
		return type.to_string() + "#" + str(type.get_uid())
	else:
		var children_string = ""
		for child in children:
			children_string += child.to_string() + ", "
		return (
			type.to_string() + "#" + str(type.get_uid())
			+ "("
			+ children_string.left(children_string.length() - 2)
			+ ")"
		) #+ str(get_all_types().keys())
