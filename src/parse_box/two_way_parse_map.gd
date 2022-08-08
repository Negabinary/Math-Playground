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
	else:
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
	var array:Array = parsing_map.get(module, {}).get(without,null)
	if count < array.size():
		return array[count]
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


func count_same_name(identifier:String, module:String) -> int:
	return parsing_map.get(module,{}).get(identifier,[]).size()


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
