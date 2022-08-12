extends Object
class_name AbstractParseBox


signal added # (type:ExprItemType, new_name:String)
signal renamed # (type:ExprItemType, old_name:String, new_name:String)
signal removed # (type:ExprItemType, old_name:String)


func parse_full(full_name:String) -> ExprItemType:
	var split := full_name.split(".")
	if split.size() == 1:
		return parse(full_name, "")
	else:
		var module := split[0]
		split.remove(0)
		var ident = split.join(".")
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
