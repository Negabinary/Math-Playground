extends AbstractJustificationBox
class_name ImportJustificationBox

"""
We again start with the assumption that imports are immutable to make things easier
It's expected that this assumption may need to be revised in later versions of the
editor with multiple files open at once.
"""

var parse_box : ImportParseBox
var imported_map : JustificationMap
var parent : AbstractJustificationBox


func _init(parent:AbstractJustificationBox, import_name:String, import_box:AbstractJustificationBox, namespace:bool):
	parse_box = ImportParseBox.new(
		parent.get_parse_box(),
		import_name,
		import_box.get_parse_box(),
		namespace
	)
	imported_map = import_box.get_justifications_snapshot()
	self.parent = parent
	parent.connect("assumption_added", self, "_on_parent_ass_added")
	parent.connect("assumption_removed", self, "_on_parent_ass_removed")
	parent.connect("updated", self, "_on_parent_updated")


func _is_assumed(expr_item:ExprItem) -> bool:
	return imported_map.is_assumed(expr_item) or parent._is_assumed(expr_item)


func _missing_justification(expr_item:ExprItem) -> Justification:
	if imported_map.has_justification_for(expr_item):
		return imported_map.get_justification_for(expr_item)
	else:
		return parent._get_justification(expr_item)


func get_parse_box() -> AbstractParseBox:
	return parse_box


func get_justifications_snapshot() -> JustificationMap:
	var result := parent.get_justifications_snapshot()
	result.merge(imported_map)
	result.merge(justification_map)
	return result


func _on_parent_ass_added(expr_item:ExprItem):
	if not imported_map.is_assumed(expr_item):
		emit_signal("assumption_added", expr_item)


func _on_parent_ass_removed(expr_item:ExprItem):
	if not imported_map.is_assumed(expr_item):
		emit_signal("assumption_removed", expr_item)


func _on_parent_updated(uid):
	if not imported_map.has_justification_for_uid(uid):
		if not justification_map.has_justification_for_uid(uid):
			emit_signal("updated", uid)
