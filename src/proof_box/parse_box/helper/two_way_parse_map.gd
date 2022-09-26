class_name TwoWayParseMap

var parsing_map := {} # <String [module], Dictionary<String [identifier], Array<ExprItemType>>>
var module_map := {} # <ExprItemType, String>
var naming_map := {} # <ExprItemType, String>


# BUILDING ================================================

# 'identifier' must NOT have dots....
func augment(value:ExprItemType, identifier:String) -> void:
	if not "" in parsing_map:
		parsing_map[""] = {}
	if not identifier in parsing_map.get("",{}):
		parsing_map[""][identifier] = []
	parsing_map[""][identifier].push_front(value)
	module_map[value] = ""
	naming_map[value] = identifier


func name_module(module_name:String) -> TwoWayParseMap:
	var npm := duplicate()
	npm.parsing_map[module_name] = parsing_map[""]
	npm.parsing_map[""] = {}
	for k in npm.module_map:
		if npm.module_map[k] == "":
			npm.module_map[k] = module_name
	return npm


func duplicate() -> TwoWayParseMap:
	var npm = get_script().new()
	npm.parsing_map = parsing_map.duplicate()
	npm.module_map = module_map.duplicate()
	npm.naming_map = naming_map.duplicate()
	return npm


func merge(other:TwoWayParseMap) -> void:
	if not "" in parsing_map:
		parsing_map[""] = {}
	for other_module in other.parsing_map:
		if other_module != "":
			parsing_map[other_module] = other.parsing_map[other_module]
		else:
			for identifier in other.parsing_map[""]:
				var previous_list = parsing_map[""].get(identifier, [])
				parsing_map[""][identifier] = other.parsing_map[""][identifier]
				parsing_map[""][identifier].append_array(previous_list)
	


# QUERYING ================================================

func parse(identifier:String, module:="") -> ExprItemType:
	var count := _count_dots(identifier)
	var without := _without_dots(identifier)
	var array:Array = parsing_map.get(module, {}).get(without,[])
	if count < array.size():
		return array[count]
	else:
		return null


func parse_ib(ib:IdentifierBuilder) -> ExprItemType:
	var array = parsing_map.get(ib.get_module(), {}).get(ib.get_identifier(), [])
	if ib.get_override_count() < array.size():
		return array[ib.get_override_count()]
	else:
		return null


func get_module(value:ExprItemType) -> String:
	return module_map.get(value, "")


func get_identifier(value:ExprItemType) -> String:
	return naming_map.get(value, ",")


func get_full_name(value:ExprItemType) -> String:
	var module := get_module(value)
	if module == "":
		return get_identifier(value)
	else:
		return module + "." + get_identifier(value)


func get_il_for(value:ExprItemType) -> IdentifierListener:
	if not value in naming_map:
		return null
	else:
		return IdentifierListener.new(
			naming_map[value],
			parsing_map[module_map[value]][naming_map[value]].find(value),
			module_map[value]
		)


func get_all_types() -> Array:
	return naming_map.keys()


func get_all_names() -> Array:
	var result := []
	for t in get_all_types():
		result.append(get_full_name(t))
	return result


func count_same_name(identifier:String, module:String) -> int:
	return parsing_map.get(module,{}).get(identifier,[]).size()


func count_same_name_ib(ib:IdentifierBuilder) -> int:
	return parsing_map.get(ib.get_module(),{}).get(ib.get_identifier(),[]).size()


func get_missing_from(other:TwoWayParseMap) -> Array:
	var missing_types := naming_map.keys()
	for t in other.naming_map.keys():
		if t in missing_types:
			missing_types.erase(t)
	return missing_types


func get_renames(other:TwoWayParseMap) -> Array:
	var result := []
	var all_types := naming_map.keys()
	for t in other.naming_map.keys():
		if t in all_types:
			if get_full_name(t) != other.get_full_name(t):
				result.append(t)
	return result

# HELPER ==================================================

static func _count_dots(identifier) -> int:
	var count := 0
	while identifier[0] == ".":
		count += 1
		identifier = identifier.right(1)
	return count


static func _without_dots(identifier) -> String:
	while identifier[0] == ".":
		identifier = identifier.right(1)
	return identifier
