extends Object
class_name ExprItem

var type : ExprItemType
var children : Array  		# of ExprItem

func _init(new_type:ExprItemType, new_children:=[]):
	type = new_type
	children = new_children


func get_type() -> ExprItemType:
	return type


func get_child_count() -> int:
	return children.size()


func get_child(idx:int) -> ExprItem:
	return children[idx]


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
