extends Object
class_name AbstractParseBox


signal renamed # (type:ExprItemType, old_name:String, new_name:String)
signal removed # (type:ExprItemType, old_name:String)


func parse(identifier:String) -> ExprItemType:
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


static func _augment_map(map:Dictionary, key:String, value:ExprItemType):
	if key in map and not (key.count(".") > 0 and key[0] != "."):
		_augment_map(map, "." + key, map[key])
	map[key] = value


static func _get_module_and_overwrite(identifier:String) -> PoolStringArray:
	var result := identifier.split(".")
	result.remove(-1)
	return result


static func _get_module_name(identifier:String) -> String:
	var mod_and_over := _get_module_and_overwrite(identifier)
	while mod_and_over[-1] == "":
		mod_and_over.remove(-1)
	return mod_and_over.join(".")


static func _get_definition_name(identifier:String) -> String:
	return identifier.split(".")[-1]


static func _get_overwrite_count(identifier:String) -> int:
	var count := 0
	for i in _get_module_and_overwrite(identifier):
		if i == "":
			count += 1
	return count
