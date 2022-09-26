extends AbstractParseBox
class_name ParseBox

var strings := [] # Bottom to Top
var types := []
var given_listeners := MultiMap.new() # <String, IdentifierListener>
var dotted_listeners := MultiMap.new() # <String, IdentifierListener>
var parent:AbstractParseBox


func _init(parent:AbstractParseBox, definitions:=[]): #<ExprItemType, String>
	assert(parent != null)
	self.parent = parent
	for definition in definitions:
		strings.append(definition.get_identifier())
		types.append(definition)
		definition.connect("updated", self, "_update_definition_name", [definition, definition.to_string()])


func get_parent() -> AbstractParseBox:
	return parent


func get_definitions() -> Array:
	return types


# Virtual Methods =========================================

func parse(ib:IdentifierBuilder) -> ExprItemType:
	if ib.has_module():
		return parent.parse(ib)
	elif ib.get_identifier() in strings:
		for i in len(strings):
			if strings[i] == ib.get_identifier():
				if ib.is_overriden():
					ib.deoverride()
				else:
					return types[i]
	return parent.parse(ib)


func get_il_for(type:ExprItemType) -> IdentifierListener:
	if type in types:
		var identifier:String = type.get_identifier()
		var ib := IdentifierListener.new(identifier)
		given_listeners.append_to(identifier, ib)
		for i in types.find(type):
			if ib.get_identifier() == strings[i]:
				ib.override()
		return ib
	else:
		var ib := parent.get_il_for(type)
		if not ib.has_module():
			var oc := 0
			for i in len(types):
				if ib.get_identifier() == strings[i]:
					oc += 1
			if oc > 0:
				ib.override(oc)
				dotted_listeners.append_to(ib.get_identifier(), ib)
		return ib


func remove_listener(il:IdentifierListener) -> void:
	for k in given_listeners.keys():
		given_listeners.remove_all(k, il)
	for k in dotted_listeners.keys():
		dotted_listeners.remove_all(k, il)
	parent.remove_listener(il)


func get_listeners_for(id:String) -> Array:
	if id in strings:
		return given_listeners.get_all(id) + dotted_listeners.get_all(id)
	else:
		return parent.get_listeners_for(id)


func get_all_types() -> TwoWayParseMap:
	var result := get_parent().get_all_types()
	for i in len(types):
		result.augment(types[i], strings[i])
	return result


func is_inside(other:AbstractParseBox) -> bool:
	return other == self or parent.is_inside(other)
	

# Own Listening ===========================================

func _update_definition_name(definition:ExprItemType, old_name:String):
	var new_name := definition.to_string()
	
	var listeners_new = get_listeners_for(new_name)
	var listeners_old = get_listeners_for(old_name)
	
	# Clear listners
	given_listeners.clear(old_name)
	dotted_listeners.clear(old_name)
	
	# First, update internally
	var idx = types.find(definition)
	strings[idx] = new_name
	definition.disconnect("updated", self, "_update_definition_name")
	definition.connect("updated", self, "_update_definition_name", [definition, new_name])
	
	# Then tell those who are about to be overshadowed
	for l in listeners_new:
		l.notify_rename()
	
	# Then tell the current definition and those who are no longer overshadowed
	for l in listeners_old:
		l.notify_rename()


# Addition Listeners ======================================

func add_addition_listener(al:ParseAdditionListener) -> void:
	parent.add_addition_listener(al)


func remove_addition_listener(al:ParseAdditionListener) -> void:
	parent.remove_addition_listener(al)
