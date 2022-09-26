extends AbstractParseBox
class_name ReparentableParseBox

var parent : AbstractParseBox

var current_mod_listeners := MultiMap.new() #<String(identifier),Listener>
var listener_to_type := {} #<Listener, Type>
var type_to_listeners := {} #<Type, Array<Listener>>

func _init(parent:AbstractParseBox):
	self.parent = parent


# RECORDS ==================================================

func add_listener(type:ExprItemType, listener:IdentifierListener):
	listener_to_type[listener] = type
	if not type in type_to_listeners:
		type_to_listeners[type] = []
	type_to_listeners[type].append(listener)
	current_mod_listeners.append_to(listener.get_identifier(), listener)


func remove_listener(listener:IdentifierListener) -> void:
	var type:ExprItemType = listener_to_type.get(listener,null)
	if type:
		type_to_listeners[type].erase(listener)
		if type_to_listeners[type].size() == 0:
			type_to_listeners.erase(type)
			if type in rescued_types:
				_forget_rescue_type(type)
		listener_to_type.erase(listener)
		current_mod_listeners.remove_all(listener.get_identifier(), listener)
	parent.remove_listener(listener)


# REPARENTING ===============================================

func set_parent(new_parent:AbstractParseBox):
	var old_parent := parent
	var old_types_map := old_parent.get_all_types()
	var new_types_map := new_parent.get_all_types()
	var missing_types := old_types_map.get_missing_from(new_types_map)
	var new_types := new_types_map.get_missing_from(old_types_map)
	_add_rescued_types(missing_types, old_types_map)
	for l in listener_to_type:
		parent.remove_listener(l)
	for al in add_listeners:
		parent.remove_addition_listener(al)
	parent = new_parent
	for al in add_listeners:
		parent.add_addition_listener(al)
	_dismiss_rescued_types(new_types)
	for l in listener_to_type.keys():
		print(self)
		l.notify_rename()


# RESCUES =================================================

signal update_rescues
var rescued_types := []
var rescued_old_names := []
var addition_listeners := {} #<Type, Al>


func _add_rescued_types(new_rescue_types:Array, old_types_map:TwoWayParseMap) -> void:
	for nrt in new_rescue_types:
		if nrt in type_to_listeners:
			if not (nrt in rescued_types):
				rescued_types.append(nrt)
				rescued_old_names.append(old_types_map.get_full_name(nrt))
				addition_listeners[nrt] = ParseAdditionListener.new(nrt)
				addition_listeners[nrt].connect("addition_notify", self, "_on_addition_notify")
				add_addition_listener(addition_listeners[nrt])
	emit_signal("update_rescues")


func _forget_rescue_type(type:ExprItemType) -> void:
	var idx = rescued_types.find(type)
	rescued_types.remove(idx)
	rescued_old_names.remove(idx)
	remove_addition_listener(addition_listeners[type])
	addition_listeners.erase(type)
	emit_signal("update_rescues")


func _dismiss_rescued_types(types):
	for add_listener in add_listeners:
		if add_listener.get_type() in types:
			add_listener.notify_addition()


func _on_addition_notify(type:ExprItemType):
	if type in rescued_types:
		_forget_rescue_type(type)
		for l in type_to_listeners[type].duplicate():
			l.notify_rename()

# Addition Listeners ======================================

var add_listeners = []

func add_addition_listener(al:ParseAdditionListener) -> void:
	add_listeners.append(al)
	parent.add_addition_listener(al)


func remove_addition_listener(al:ParseAdditionListener) -> void:
	add_listeners.erase(al)
	parent.remove_addition_listener(al)


# OVERRIDES ===============================================

func parse(ib:IdentifierBuilder) -> ExprItemType:
	return parent.parse(ib)


func get_il_for(type:ExprItemType) -> IdentifierListener:
	if type in rescued_types:
		var new_il = IdentifierListener.new("[MISSING]")
		add_listener(type, new_il)
		return new_il
	else:
		var result := parent.get_il_for(type)
		add_listener(type, result)
		return result


func get_all_types() -> TwoWayParseMap: # <String, ExprItem>
	return parent.get_all_types()


func get_listeners_for(identifier:String) -> Array:
	return current_mod_listeners.get_all(identifier)


func is_inside(other:AbstractParseBox) -> bool:
	return other == self or parent.is_inside(other)
