extends AbstractParseBox
class_name ReparentableParseBox

var parent : AbstractParseBox

var current_mod_listeners := MultiMap.new() #<String(identifier),Listener>
var listener_to_type := {} #<Listener, Type>
var type_to_listener := {} #<Type, Listener>

func _init(parent:AbstractParseBox):
	self.parent = parent


# RECORDS ==================================================

func add_listener(type:ExprItemType, listener:IdentifierListener):
	listener_to_type[listener] = type
	type_to_listener[type] = listener
	current_mod_listeners.append_to(listener.get_identifier(), listener)


func remove_listener(listener:IdentifierListener) -> void:
	var type:ExprItemType = listener_to_type.get(listener,null)
	if type:
		type_to_listener.erase(type)
		listener_to_type.erase(listener)
		if listener.get_module() == "":
			current_mod_listeners.remove_all(listener.get_identifier(), listener)


# REPARENTING ===============================================

func set_parent(new_parent:AbstractParseBox):
	var old_parent := parent
	parent = new_parent
	var old_types_map := parent.get_all_types()
	var new_types_map := new_parent.get_all_types()
	for m in old_types_map.get_missing_from(new_types_map):
		type_to_listener[m].notify_delete()
	# signal renamed types
	for m in new_types_map.get_renames(old_types_map):
		type_to_listener[m].notify_rename()
	# signal added types
	var new_types = new_types_map.get_missing_from(old_types_map)
	for m in new_types:
		#emit_signal("added", m, new_types_map.get_full_name(m))
		pass


# OVERRIDES ===============================================

func parse(ib:IdentifierBuilder) -> ExprItemType:
	return parent.parse(ib)


func get_il_for(type:ExprItemType) -> IdentifierListener:
	var result := parent.get_il_for(type)
	add_listener(type, result)
	return result


func get_all_types() -> TwoWayParseMap: # <String, ExprItem>
	return parent.get_all_types()


func get_listeners_for(identifier:String) -> Array:
	return current_mod_listeners.get_all(identifier)
