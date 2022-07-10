extends AbstractParseBox
class_name ParseBox


var definitions := {}  # <String, ExprItemType>
var parent:AbstractParseBox


func _init(parent:AbstractParseBox, definitions:=[]): #<ExprItemType, String>
	self.parent = parent
	if parent:
		parent.connect("removed", self, "_on_parent_removed")
		parent.connect("renamed", self, "_on_parent_renamed")
	for definition in definitions:
		self.definitions[definition.to_string()] = definition
		definition.connect("renamed", self, "_update_definition_name", [definition, definition.to_string()])


func get_parent() -> AbstractParseBox:
	return parent


# OVERRIDES ===============================================


func parse(string:String) -> ExprItemType:
	if string.count(".") == 0:
		if string in definitions:
			return definitions[string]
	elif _get_module_name(string) == "":
		if _get_definition_name(string) in definitions:
			var new_string := string.substr(1)
			if get_parent():
				return get_parent().parse(new_string)
			else:
				return null
	if get_parent():
		return get_parent().parse(string)
	return null


func get_name_for(type:ExprItemType) -> String:
	if type in definitions.values():
		for name in definitions:
			if definitions[name] == type:
				return name
	if get_parent():
		var name_from_parent := get_parent().get_name_for(type)
		if name_from_parent in definitions:
			return "." + name_from_parent
		else:
			return name_from_parent
	else:
		return ","


func get_import_map() -> Dictionary:
	if get_parent():
		return get_parent().get_import_map()
	else:
		return {}


# RETURNED DICTIONARY WILL BE EDITED
func get_all_types() -> Dictionary:
	var result : Dictionary
	if get_parent():
		result = get_parent().get_all_types()
	else:
		result = {}
	for definition in definitions:
		_augment_map(result, definition, definitions[definition])
	return result


# DEFINITIONS =============================================


func get_definitions() -> Array:
	return definitions.values()


func _update_definition_name(definition:ExprItemType, old_name:String):
	definitions.erase(old_name)
	definition.disconnect("renamed", self, "_update_definition_name")
	definition.connect("renamed", self, "_update_definition_name", [definition, definition.to_string()])
	var shadow_count := 0
	while parse((".".repeat(shadow_count) + definition.to_string())) != null:
		shadow_count += 1
	definitions[definition.to_string()] = definition
	emit_signal("renamed", definition, old_name, get_name_for(definition))
	for i in shadow_count:
		emit_signal("renamed",
			parse((".".repeat(i+1) + definition.to_string())),
			(".".repeat(i) + definition.to_string()),
			(".".repeat(i+1) + definition.to_string())
		)


func _on_parent_renamed(type:ExprItemType, old_name:String, new_name:String):
	if old_name in definitions:
		old_name = "." + old_name
	if new_name in definitions:
		new_name = "." + new_name
	emit_signal("renamed", type, old_name, new_name)


func _on_parent_removed(type:ExprItemType, old_name:String):
	if old_name in definitions:
		old_name = "." + old_name
	emit_signal("removed", type, old_name)
