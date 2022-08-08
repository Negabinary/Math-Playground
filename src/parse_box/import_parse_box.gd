extends AbstractParseBox
class_name ImportParseBox


"""
This file assumes that anything in an import is immutable.
"""

var parent : AbstractParseBox
var import_name : String
var import_box : AbstractParseBox
var import_map : Dictionary # <String, AbstractParseBox>
var imported_type_map : TwoWayParseMap
var namespace : bool


func _init(parent:AbstractParseBox, import_name:String, import_box:AbstractParseBox, namespace:bool):
	self.import_name = import_name
	self.import_box = import_box
	self.namespace = namespace
	self.parent = parent
	parent.connect("removed", self, "_on_parent_removed")
	parent.connect("renamed", self, "_on_parent_renamed")
	_set_up_import_map()
	_set_up_imported_type_map()


func _set_up_import_map():
	self.import_map = import_box.get_import_map()
	if namespace:
		self.import_map[import_name] = import_box


func _set_up_imported_type_map():
	var import_all_types := import_box.get_all_types()
	self.imported_type_map = TwoWayParseMap.new()
	for type_name in import_all_types:
		if namespace:
			if _get_module_name(type_name) == "":
				imported_type_map.augment(import_name + "." + type_name, import_all_types[type_name])
			else:
				imported_type_map.augment(type_name, import_all_types[type_name])
		else:
			imported_type_map.augment(type_name, import_all_types[type_name])


func parse(string:String, module:String) -> ExprItemType:
	var result = imported_type_map.parse(string, module)
	if result:
		return result
	else:
		if namespace or module != "":
			return parent.parse(string, module)
		else:
			var removed_dots = imported_type_map.count_same_name(string, module)
			return parent.parse(string.right(removed_dots), "")


func get_name_for(type:ExprItemType) -> String:
	var imported := imported_type_map.get_full_name(type)
	if imported == ",":
		return parent.get_name_for(type)
	else:
		return imported


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


func _on_parent_added(type:ExprItemType, new_name:String):
	emit_signal("added", type, new_name)


func _on_parent_renamed(type:ExprItemType, old_name:String, new_name:String):
	emit_signal("renamed", type, old_name, new_name)


func _on_parent_removed(type:ExprItemType, old_name:String):
	emit_signal("removed", type, old_name)


func get_all_types() -> TwoWayParseMap:
	return parent.get_all_types().merge(imported_type_map)
