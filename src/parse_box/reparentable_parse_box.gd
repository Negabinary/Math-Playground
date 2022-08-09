extends AbstractParseBox
class_name ReparentableParseBox

var parent : AbstractParseBox


func _init(parent:AbstractParseBox):
	self.parent = parent
	parent.connect("added", self, "_on_parent_added")
	parent.connect("removed", self, "_on_parent_removed")
	parent.connect("renamed", self, "_on_parent_renamed")


# REPARENTING ===============================================

func set_parent(new_parent:AbstractParseBox):
	var old_parent := parent
	parent = new_parent
	var old_types_map := parent.get_all_types()
	var new_types_map := new_parent.get_all_types()
	# signal removed types
	var missing_types = old_types_map.get_missing_from(new_types_map)
	for m in missing_types:
		emit_signal("removed", m, old_types_map.get_full_name(m))
	# signal renamed types
	for m in new_types_map.get_renames(old_types_map):
		emit_signal("renamed", m, old_types_map.get_full_name(m), new_types_map.get_full_name(m))
	# signal added types
	var new_types = new_types_map.get_missing_from(old_types_map)
	for m in new_types:
		emit_signal("added", m, new_types_map.get_full_name(m))
	# stop listening to old parent
	old_parent.disconnect("added", self, "_on_parent_added")
	old_parent.disconnect("removed", self, "_on_parent_removed")
	old_parent.disconnect("renamed", self, "_on_parent_renamed")
	# listen to new parent
	parent.connect("added", self, "_on_parent_added")
	parent.connect("removed", self, "_on_parent_removed")
	parent.connect("renamed", self, "_on_parent_renamed")


# OVERRIDES ===============================================

func parse(identifier:String, module:String) -> ExprItemType:
	return parent.parse(identifier, module)


func get_name_for(type:ExprItemType) -> String:
	return parent.get_name_for(type)


func get_all_types() -> TwoWayParseMap: # <String, ExprItem>
	return parent.get_all_types()


# UPDATES =================================================

func _on_parent_added(type:ExprItemType, new_name:String):
	emit_signal("added", type, new_name)


func _on_parent_renamed(type:ExprItemType, old_name:String, new_name:String):
	emit_signal("renamed", type, old_name, new_name)


func _on_parent_removed(type:ExprItemType, old_name:String):
	emit_signal("removed", type, old_name)
