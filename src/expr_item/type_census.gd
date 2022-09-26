class_name TypeCensus

var map := {} #<ExprItemType,Dict<String,Array<object>>>


func add_entry(kind:String, object, types:Dictionary):
	for type in types:
		if not type in map:
			map[type] = {}
		if not kind in map[type]:
			map[type][kind] = []
		map[type][kind].append(object)


func remove_entry(type:ExprItemType):
	map.erase(type)


func get_summary_for(type:ExprItemType) -> Dictionary: # <String,int>
	if not type in map:
		return {}
	var entry = map[type]
	var result := {}
	for k in entry:
		result[k] = entry[k].size()
	return result


func merge(other:TypeCensus) -> void:
	for type in other.map:
		if not (type in map):
			map[type] = {}
		for kind in other.map[type]:
			if not (kind in map[type]):
				map[type][kind] = []
			map[type][kind].append_array(other.map[type][kind])


func print_result(context:AbstractParseBox) -> String:
	var result := ""
	for type in map:
		var il := context.get_il_for(type)
		result = result + il.get_full_string() + ":"
		context.remove_listener(il)
		for kind in map[type]:
			result = result + " (" + kind + ":" + str(len(map[type][kind])) + ")"
		result += "\n"
	return result


func has_type(t:ExprItemType) -> bool:
	return t in map
