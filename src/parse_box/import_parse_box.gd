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
	parent.connect("added", self, "_on_parent_added")
	parent.connect("removed", self, "_on_parent_removed")
	parent.connect("renamed", self, "_on_parent_renamed")
	imported_type_map = import_box.get_all_types()
	if namespace:
		imported_type_map = imported_type_map.name_module(import_name)


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


func _on_parent_added(type:ExprItemType, new_name:String):
	emit_signal("added", type, new_name)


func _on_parent_renamed(type:ExprItemType, old_name:String, new_name:String):
	emit_signal("renamed", type, old_name, new_name)


func _on_parent_removed(type:ExprItemType, old_name:String):
	emit_signal("removed", type, old_name)


func get_all_types():
	var parent_map = parent.get_all_types()
	parent_map.merge(imported_type_map)
	return parent_map
