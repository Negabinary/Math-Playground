extends AbstractParseBox
class_name ImportParseBox


"""
This file assumes that anything in an import is immutable.
"""


var parent : AbstractParseBox
var import_name : String
var import_box : AbstractParseBox
var namespace : bool
var import_map : Dictionary # <String, AbstractParseBox>
var imported_type_map : Dictionary # <String, ExprItemType>


func _init(parent:AbstractParseBox, import_name:String, import_box:AbstractParseBox, namespace:bool):
	self.import_name = import_name
	self.import_box = import_box
	self.namespace = namespace
	self.parent = parent
	if parent:
		parent.connect("removed", self, "_on_parent_removed")
		parent.connect("renamed", self, "_on_parent_renamed")
	self.import_map = import_box.get_import_map()
	if namespace:
		self.import_map[import_name] = import_box
	var import_all_types := import_box.get_all_types()
	self.imported_type_map = {}
	for type_name in import_all_types:
		if namespace:
			if _get_module_name(type_name) == "":
				_augment_map(self.imported_type_map, import_name + "." + type_name, import_all_types[type_name])
			else:
				_augment_map(self.imported_type_map, type_name, import_all_types[type_name])
		else:
			_augment_map(self.imported_type_map, type_name, import_all_types[type_name])


func parse(string:String) -> ExprItemType:
	if string in imported_type_map:
		return imported_type_map[string]
	if parent:
		return parent.parse(string)
	return null


func get_import_map() -> Dictionary:
	var base_map : Dictionary
	if parent:
		base_map = parent.get_import_map()
	else:
		base_map = {}
	for n in import_map:
		if not n in base_map:
			base_map[n] = import_map[n]
	return base_map


func get_name_for(type:ExprItemType) -> String:
	for type_string in imported_type_map:
		if imported_type_map[type_string] == type:
			return type_string
	return ","


func _on_parent_renamed(type:ExprItemType, old_name:String, new_name:String):
	emit_signal("renamed", type, old_name, new_name)


func _on_parent_removed(type:ExprItemType, old_name:String):
	emit_signal("removed", type, old_name)


func get_all_types() -> Dictionary:
	var result : Dictionary
	if parent:
		result = parent.get_all_types()
	else:
		result = {}
	for r in imported_type_map:
		_augment_map(result, r, imported_type_map[r])
	return result
