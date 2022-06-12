extends Object
class_name ParseBox


var parent : ParseBox

var imports := {} # <ParseBox>
var definitions := {}  # <String, ExprItemType>


func _init(parent:ParseBox, definitions:=[], imports:={}): #<ExprItemType, String>
	self.parent = parent
	for definition in definitions:
		self.definitions[definition.to_string()] = definition
		definition.connect("renamed", self, "_update_definition_name", [definition, definition.to_string()])
	self.imports = imports


func get_parent() -> ParseBox:
	return parent


func get_child_extended_with(definitions:Array) -> ParseBox:
	if definitions.size() > 0:
		return get_script().new(self, definitions)
	else:
		return self


# IMPORTS =================================================


# returns null if name cannot be found
func find_import(import_name):
	var result = imports.get(import_name)
	if result:
		return result
	else:
		return get_parent().find_import(import_name)


# DEFINITIONS =============================================


func get_definitions() -> Array:
	return definitions.values()


func _update_definition_name(definition:ExprItemType, old_name:String):
	definitions.erase(old_name)
	definition.disconnect("renamed", self, "_update_definition_name")
	definition.connect("renamed", self, "_update_definition_name", [definition, definition.to_string()])
	definitions[definition.to_string()] = definition


func is_defined(type:ExprItemType):
	if type in get_definitions():
		return true
	for import in imports:
		if imports[import].is_defined(type):
			return true
	return parent.is_defined(type)


func parse(string:String) -> ExprItemType:
	if string in definitions:
		return definitions[string]
	for import in imports:
		var p = imports[import].parse(string)
		if p != null:
			return p
	if parent != null:
		return parent.parse(string)
	else:
		return null
