extends AbstractJustificationBox
class_name JustificationBox

var assumptions : Array
var parent : AbstractJustificationBox

var parse_box : ParseBox

func _init(parent:AbstractJustificationBox, definitions:Array, assumptions:Array):
	parse_box = ParseBox.new(
		parent.get_parse_box(),
		definitions
	)
	self.assumptions = assumptions
	self.parent = parent
	parent.connect("assumption_added", self, "_on_parent_ass_added")
	parent.connect("assumption_removed", self, "_on_parent_ass_removed")
	parent.connect("updated", self, "_on_parent_updated")


func set_justification(expr_item:ExprItem, justification) -> void:
	for assumption in assumptions:
		if expr_item.compare(assumption):
			return
	.set_justification(expr_item, justification)


func get_justification_or_missing(expr_item:ExprItem) -> Justification:
	for assumption in assumptions:
		if expr_item.compare(assumption):
			return AssumptionJustification.new()
	return .get_justification_or_missing(expr_item)


func _missing_justification(expr_item:ExprItem) -> Justification:
	return parent.get_justification_or_missing(expr_item)


func get_justifications_snapshot() -> JustificationMap:
	var result := parent.get_justifications_snapshot()
	result.merge(justification_map)
	return result

func get_parse_box() -> AbstractParseBox:
	return parse_box


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
