extends AbstractParseBox
class_name ReparentableParseBox

#signal renamed # (type:ExprItemType, old_name:String, new_name:String)
#signal removed # (type:ExprItemType, old_name:String)

var parent : AbstractParseBox


func _init(parent:AbstractParseBox):
	self.parent = parent


func set_parent(new_parent:AbstractParseBox):
	var old_parent := parent
	var old_types_map := parent.get_all_types()
	var new_types_map := new_parent.get_all_types()
	var new_types := new_parent.get_all_types().values()
	parent = new_parent
	for old_type_name in old_types_map:
		if not old_type in new_types:
			emit_signal("removed", old_types_map[old_type_name], old_type_name)


func parse(identifier:String, module:String) -> ExprItemType:
	assert(false) # abstract
	return null


func get_name_for(type:ExprItemType) -> String:
	assert(false) # abstract
	return ""


func get_import_map() -> Dictionary: # <String, AbstractParseBox>
	assert(false) # abstract
	return {}


func get_all_types() -> Dictionary: # <String, ExprItem>
	assert(false)
	return {}
