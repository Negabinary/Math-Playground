class_name ScopeStack

var parent : ScopeStack
var dict : Dictionary


func _init(new_dict:={}, new_parent:ScopeStack=null):
	parent = new_parent
	dict = new_dict.duplicate()


func new_child_context(new_dict:={}) -> ScopeStack:
	return get_script().new(new_dict, self)


func get_from_scope(key):
	if key in dict:
		return dict[key]
	elif parent != null:
		return parent.get_from_scope(key)
	else:
		return null


func put(key, value) -> void:
	dict[key] = value


func put_all(new_dict) -> void:
	for k in new_dict:
		dict[k] = new_dict[k]
