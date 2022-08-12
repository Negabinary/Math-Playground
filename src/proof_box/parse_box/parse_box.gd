extends AbstractParseBox
class_name ParseBox


var definitions := {}  # <String, ExprItemType>
var parent:AbstractParseBox


func _init(parent:AbstractParseBox, definitions:=[]): #<ExprItemType, String>
	self.parent = parent
	parent.connect("added", self, "_on_parent_added")
	parent.connect("removed", self, "_on_parent_removed")
	parent.connect("renamed", self, "_on_parent_renamed")
	for definition in definitions:
		self.definitions[definition.to_string()] = definition
		definition.connect("renamed", self, "_update_definition_name", [definition, definition.to_string()])


func get_parent() -> AbstractParseBox:
	return parent


# OVERRIDES ===============================================


func parse(string:String, module:String) -> ExprItemType:
	if module != "":
		return parent.parse(string, module)
	elif string.count(".") == 0:
		if string in definitions:
			return definitions[string]
		else:
			return parent.parse(string, module)
	else:
		if TwoWayParseMap._without_dots(string) in definitions:
			return parent.parse(string.substr(1, string.length() - 1), "")
		else:
			return parent.parse(string, module)


func get_name_for(type:ExprItemType) -> String:
	if type in definitions.values():
		for name in definitions:
			if definitions[name] == type:
				return name
	var name_from_parent := get_parent().get_name_for(type)
	if name_from_parent in definitions:
		return "." + name_from_parent
	else:
		return name_from_parent


func get_all_types() -> TwoWayParseMap:
	var result := get_parent().get_all_types()
	for definition in definitions:
		result.augment(definitions[definition], definition)
	return result


# DEFINITIONS =============================================


func get_definitions() -> Array:
	return definitions.values()


# UPDATES =================================================


func _on_parent_added(type:ExprItemType, new_name:String):
	if TwoWayParseMap._without_dots(new_name) in definitions:
		new_name = "." + new_name
	emit_signal("added", type, new_name)


func _on_parent_renamed(type:ExprItemType, old_name:String, new_name:String):
	if TwoWayParseMap._without_dots(old_name) in definitions:
		old_name = "." + old_name
	if TwoWayParseMap._without_dots(new_name) in definitions:
		new_name = "." + new_name
	emit_signal("renamed", type, old_name, new_name)


func _on_parent_removed(type:ExprItemType, old_name:String):
	if TwoWayParseMap._without_dots(old_name) in definitions:
		old_name = "." + old_name
	emit_signal("removed", type, old_name)


func _update_definition_name(definition:ExprItemType, old_name:String):
	# Update anything it will overshadow
	var new_name := definition.to_string()
	var newly_shadowed := parent.parse(new_name, "")
	while newly_shadowed:
		emit_signal("renamed", newly_shadowed, new_name, "." + new_name)
		new_name = "." + new_name
		newly_shadowed = parent.parse(new_name, "")
	
	# Update the definition that has been changed
	definitions.erase(old_name)
	definitions[definition.to_string()] = definition
	definition.disconnect("renamed", self, "_update_definition_name")
	definition.connect("renamed", self, "_update_definition_name", [definition, definition.to_string()])
	emit_signal("renamed", definition, old_name, definition.to_string())
	
	# Update anything it previously overshadowed
	var newly_unshadowed := parent.parse(old_name, "")
	while newly_unshadowed:
		emit_signal("renamed", newly_unshadowed, "." + old_name, old_name)
		old_name = "." + old_name
		newly_unshadowed = parent.parse(old_name, "")
