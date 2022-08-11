extends AbstractJustificationBox
class_name ReparentableJustificationBox

var parse_box : ReparentableParseBox
var parent : AbstractJustificationBox


func _init(parent:AbstractJustificationBox):
	parse_box = ReparentableParseBox.new(
		parent.get_parse_box()
	)
	self.parent = parent
	parent.connect("assumption_added", self, "_on_parent_ass_added")
	parent.connect("assumption_removed", self, "_on_parent_ass_removed")
	parent.connect("updated", self, "_on_parent_updated")


func set_parent(new_parent:AbstractJustificationBox):
	var old_parent = parent
	parent.disconnect("assumption_added", self, "_on_parent_ass_added")
	parent.disconnect("assumption_removed", self, "_on_parent_ass_removed")
	parent.disconnect("updated", self, "_on_parent_updated")
	self.parent = parent
	parent.connect("assumption_added", self, "_on_parent_ass_added")
	parent.connect("assumption_removed", self, "_on_parent_ass_removed")
	parent.connect("updated", self, "_on_parent_updated")
	parse_box.set_parent(new_parent.get_parse_box())
	
	var old_summary = parent.get_justifications_snapshot()
	var new_summary = new_parent.get_justifications_snapshot()
	for old_assumption in old_summary.get_assumptions_not_in(new_summary):
		emit_signal("assumption_removed", old_assumption)
	for old_assumption in new_summary.get_assumptions_not_in(old_summary):
		emit_signal("assumption_added", old_assumption)
	for uid in new_summary.get_updated_uids(old_summary):
		emit_signal("updated", uid)


func _is_assumed(expr_item:ExprItem) -> bool:
	return parent._is_assumed(expr_item)


func _missing_justification(expr_item:ExprItem) -> Justification:
	return parent._get_justification(expr_item)


# UPDATES =================================================

func _on_parent_ass_added(expr_item:ExprItem):
	emit_signal("assumption_added", expr_item)


func _on_parent_ass_removed(expr_item:ExprItem):
	emit_signal("assumption_removed", expr_item)


func _on_parent_updated(uid):
	if justification_map.has_justification_for_uid(uid):
		return
	emit_signal("updated", uid)
