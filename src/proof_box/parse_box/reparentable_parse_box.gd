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
		type_to_listeners.get(type,[]).erase(listener)
		if type in type_to_listeners and type_to_listeners[type].size() == 0:
			type_to_listeners.erase(type)
			if type in rescued_types:
				_forget_rescue_type(type)
		listener_to_type.erase(listener)
		current_mod_listeners.remove_all(listener.get_identifier(), listener)
	parent.remove_listener(listener)


# REPARENTING ===============================================

func set_parent(new_parent:AbstractParseBox, types_to_keep:Array):
	var old_parent := parent
	var old_types_map := old_parent.get_all_types()
	var new_types_map := new_parent.get_all_types()
	var missing_types := old_types_map.get_missing_from(new_types_map)
	var new_types := new_types_map.get_missing_from(old_types_map)
	for l in listener_to_type:
		parent.remove_listener(l)
	for al in add_listeners:
		parent.remove_addition_listener(al)
	parent = new_parent
	if missing_types.size() > 0:
		_add_rescued_types(missing_types, old_types_map, types_to_keep)
	for al in add_listeners:
		parent.add_addition_listener(al)
	_dismiss_rescued_types(new_types)
	for l in listener_to_type.keys():
		if l in listener_to_type:
			l.notify_rename()


# RESCUES =================================================

signal update_rescues
signal request_absolve_responsibility # (Array<ExprItemType>,Array<String>)
var rescued_types := []
var rescued_old_names := []
var addition_listeners := {} #<Type, Al>


func get_rescue_types() -> Array:
	return rescued_types


func get_rescue_types_old_names() -> Array:
	return rescued_old_names


func _add_rescued_types(new_rescue_types:Array, old_types_map:TwoWayParseMap, types_to_keep:Array) -> void:
	var undesired_types := []
	var undesired_names := []
	for nrt in new_rescue_types:
		if nrt in type_to_listeners:
			if not (nrt in rescued_types):
				if nrt in types_to_keep:
					rescued_types.append(nrt)
					rescued_old_names.append(old_types_map.get_full_name(nrt))
					addition_listeners[nrt] = ParseAdditionListener.new(nrt)
					addition_listeners[nrt].connect("addition_notify", self, "_on_addition_notify")
					add_addition_listener(addition_listeners[nrt])
				else:
					undesired_types.append(nrt)
					undesired_names.append(old_types_map.get_full_name(nrt))
	if undesired_types.size() > 0:
		emit_signal("request_absolve_responsibility", undesired_types, undesired_names)
	emit_signal("update_rescues")


func take_responsibility_for(new_rescue_types:Array, rescue_types_names:Array, desired_types:Array):
	var unwanted_types := []
	var unwanted_names := []
	for nrtid in new_rescue_types.size():
		var nrt : ExprItemType = new_rescue_types[nrtid]
		if nrt in desired_types:
			if not (nrt in rescued_types):
				rescued_types.append(nrt)
				rescued_old_names.append(rescue_types_names[nrtid])
				addition_listeners[nrt] = ParseAdditionListener.new(nrt)
				addition_listeners[nrt].connect("addition_notify", self, "_on_addition_notify")
				add_addition_listener(addition_listeners[nrt])
			for l in type_to_listeners[nrt]:
				parent.remove_listener(l)
		else:
			unwanted_types.append(nrt)
			unwanted_names.append(rescue_types_names[nrtid])
	if unwanted_types.size() > 0:
		emit_signal("request_absolve_responsibility", unwanted_types, unwanted_names)
	for nrt in new_rescue_types:
		for l in type_to_listeners.get(nrt, []).duplicate():
			if l in type_to_listeners.get(nrt, []):
				l.notify_rename()
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
		var idx = rescued_types.size() - rescued_types.find(type) - 1
		var new_il = IdentifierListener.new("[MISSING]",idx)
		add_listener(type, new_il)
		return new_il
	else:
		var result := parent.get_il_for(type)
		if result.get_identifier() == "[MISSING]" and (not result.has_module()):
			result.override(rescued_types.size())
		add_listener(type, result)
		return result


func get_all_types() -> TwoWayParseMap: # <String, ExprItem>
	var parent_map = parent.get_all_types()
	for t in rescued_types:
		parent_map.augment(t, "[MISSING]")
	return parent_map


func get_listeners_for(identifier:String) -> Array:
	return current_mod_listeners.get_all(identifier)


func is_inside(other:AbstractParseBox) -> bool:
	return other == self or parent.is_inside(other)
