extends AbstractJustificationBox
class_name JustificationBox

var assumptions : Array
var parent : AbstractJustificationBox


func _init(parent:AbstractJustificationBox, assumptions:=[]):
	self.assumptions = assumptions
	self.parent = parent
	parent.connect("assumption_added", self, "_on_parent_ass_added")
	parent.connect("assumption_removed", self, "_on_parent_ass_removed")
	parent.connect("updated", self, "_on_parent_updated")


func set_justification(expr_item:ExprItem, justification) -> void:
	if not _is_assumed(expr_item):
		.set_justification(expr_item, justification)


func _is_assumed(expr_item:ExprItem) -> bool:
	for assumption in assumptions:
		if expr_item.compare(assumption):
			return true
	return parent._is_assumed(expr_item)


func _missing_justification(expr_item:ExprItem) -> Justification:
	return null #parent._get_justification(expr_item)


func get_justifications_snapshot() -> JustificationMap:
	var result := parent.get_justifications_snapshot()
	result.merge(justification_map)
	for assumption in assumptions:
		result.add_assumption(assumption)
	return result


func _on_parent_ass_added(expr_item:ExprItem):
	for assumption in assumptions:
		if assumption.compare(expr_item):
			return
	emit_signal("assumption_added", expr_item)


func _on_parent_ass_removed(expr_item:ExprItem):
	for assumption in assumptions:
		if assumption.compare(expr_item):
			return
	emit_signal("assumption_removed", expr_item)


func _on_parent_updated(uid):
	for assumption in assumptions:
		if assumption.get_unique_name() == uid:
			return
	if justification_map.has_justification_for_uid(uid):
		return
	emit_signal("updated", uid)


func is_child_of(other:AbstractJustificationBox) -> bool:
	if self == other:
		return true
	else:
		return parent.is_child_of(other)
