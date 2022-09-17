extends AbstractJustificationBox
class_name ReparentableJustificationBox

var parent : AbstractJustificationBox


func _init(parent:AbstractJustificationBox):
	self.parent = parent
	parent.connect("assumption_added", self, "_on_parent_ass_added")
	parent.connect("assumption_removed", self, "_on_parent_ass_removed")


func set_parent(new_parent:AbstractJustificationBox):
	var old_parent = parent
	parent.disconnect("assumption_added", self, "_on_parent_ass_added")
	parent.disconnect("assumption_removed", self, "_on_parent_ass_removed")
	self.parent = new_parent
	parent.connect("assumption_added", self, "_on_parent_ass_added")
	parent.connect("assumption_removed", self, "_on_parent_ass_removed")
	
	var old_summary = old_parent.get_justifications_snapshot()
	var new_summary = new_parent.get_justifications_snapshot()
	for old_assumption in old_summary.get_assumptions_not_in(new_summary):
		emit_signal("assumption_removed", old_assumption)
	for old_assumption in new_summary.get_assumptions_not_in(old_summary):
		emit_signal("assumption_added", old_assumption)


func _is_assumed(expr_item:ExprItem) -> bool:
	return parent._is_assumed(expr_item)


func is_child_of(other:AbstractJustificationBox) -> bool:
	if self == other:
		return true
	else:
		return parent.is_child_of(other)


func get_justifications_snapshot() -> JustificationMap:
	return parent.get_justifications_snapshot()


# UPDATES =================================================

func _on_parent_ass_added(expr_item:ExprItem):
	emit_signal("assumption_added", expr_item)


func _on_parent_ass_removed(expr_item:ExprItem):
	emit_signal("assumption_removed", expr_item)


func _on_parent_updated(uid):
	if justification_map.has_justification_for_uid(uid):
		return
	emit_signal("updated", uid)
