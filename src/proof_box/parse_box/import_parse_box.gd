extends AbstractParseBox
class_name ImportParseBox


"""
This file assumes that anything in an import is immutable.
"""

var parent : AbstractParseBox
var import_name : String
var import_box : AbstractParseBox
var import_map : Dictionary # <String, AbstractParseBox>
var unnamed_type_map :TwoWayParseMap
var named_type_map : TwoWayParseMap
var imported_type_map : TwoWayParseMap
var namespace : bool
var given_listeners := [] # <IdentifierListener>
var dotted_listeners := [] # <IdentifierListener>


func _init(parent:AbstractParseBox, import_name:String, import_box:AbstractParseBox, namespace:bool):
	self.import_name = import_name
	self.import_box = import_box
	self.namespace = namespace
	self.parent = parent
	unnamed_type_map = import_box.get_all_types()
	named_type_map = unnamed_type_map.name_module(import_name)
	imported_type_map = named_type_map if namespace else unnamed_type_map


func is_using_namespace() -> bool:
	return namespace


func set_namespace(val:bool) -> void:
	namespace = val
	imported_type_map = named_type_map if namespace else unnamed_type_map
	for gl in given_listeners.duplicate():
		gl.notify_rename()
	for dl in dotted_listeners.duplicate():
		dl.notify_rename()


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
		var il := parent.get_il_for(type)
		dotted_listeners.append(il)
		return il
	else:
		given_listeners.append(imported)
		return imported


func remove_listener(il:IdentifierListener) -> void:
	given_listeners.erase(il)
	dotted_listeners.erase(il)
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
