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
	imported_type_map = import_box.get_all_types()
	if namespace:
		imported_type_map = imported_type_map.name_module(import_name)


# Virtual Methods =========================================

func parse(ib:IdentifierBuilder) -> ExprItemType:
	var result = imported_type_map.parse_ib(ib)
	if result:
		return result
	else:
		if namespace or ib.get_module() != "":
			return parent.parse(ib)
		else:
			ib.deoverride(imported_type_map.count_same_name_ib(ib))
			return parent.parse(ib)


func get_il_for(type:ExprItemType) -> IdentifierListener:
	var imported := imported_type_map.get_il_for(type)
	if imported == null:
		return parent.get_il_for(type)
	else:
		return imported


func remove_listener(il:IdentifierListener) -> void:
	parent.remove_listener(il)


func get_listeners_for(id:String) -> Array:
	return parent.get_listeners_for(id)


func get_all_types():
	var parent_map = parent.get_all_types()
	parent_map.merge(imported_type_map)
	return parent_map


func is_inside(other:AbstractParseBox) -> bool:
	return other == self or parent.is_inside(other) or import_box.is_inside(other)


# Addition Listeners ======================================

func add_addition_listener(al:ParseAdditionListener) -> void:
	parent.add_addition_listener(al)


func remove_addition_listener(al:ParseAdditionListener) -> void:
	parent.remove_addition_listener(al)
