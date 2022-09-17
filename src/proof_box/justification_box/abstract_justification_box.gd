class_name AbstractJustificationBox

signal assumption_added # (ExprItem)
signal assumption_removed # (ExprItem)
signal updated # (String[uname])

var justification_map := JustificationMap.new()


func set_justification(expr_item:ExprItem, justification) -> void:
	justification_map.add_entry(expr_item, justification)
	var uname = expr_item.get_unique_name()
	emit_signal("updated", expr_item.get_unique_name())


func get_justification_or_missing(expr_item:ExprItem) -> Justification:
	if _is_assumed(expr_item):
		return AssumptionJustification.new()
	return _get_justification(expr_item)


func _is_assumed(expr_item:ExprItem) -> bool:
	assert(false) # virtual
	return false


# Could be extended
func _find_justification_in_tree(expr_item:ExprItem) -> Justification:
	justification_map.add_missing(expr_item)
	return justification_map.get_justification_for(expr_item)


func _get_justification(expr_item:ExprItem) -> Justification:
	var justification = justification_map.get_justification_for(expr_item)
	if justification_map.has_justification_for(expr_item):
		return justification
	return _find_justification_in_tree(expr_item)


func get_justifications_snapshot() -> JustificationMap:
	assert(false) # virtual
	return null


func is_child_of(other:AbstractJustificationBox) -> bool:
	assert(false) # virtual
	return false
