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
	var justification = _get_justification(expr_item)
	if justification:
		return justification
	return MissingJustification.new()


func _is_assumed(expr_item:ExprItem) -> bool:
	assert(false) # virtual
	return false


func _missing_justification(expr_item:ExprItem) -> Justification:
	assert(false) # virtual
	return null


func _get_justification(expr_item:ExprItem) -> Justification:
	if justification_map.has_justification_for(expr_item):
		return justification_map.get_justification_for(expr_item)
	return _missing_justification(expr_item)


func get_justifications_snapshot() -> JustificationMap:
	assert(false) # virtual
	return null


func get_parse_box() -> AbstractParseBox:
	assert(false) # virtual
	return null


"""
var MJ := load("res://src/proof_step/justifications/missing_justification.gd")

func get_justification_or_missing_for(expr_item:ExprItem):
	var j = get_justification_for(expr_item)
	if j:
		return j
	else:
		j = MJ.new()
		add_justification(expr_item, j)
		return j


func get_justification_for(expr_item:ExprItem):
	if _is_assumed(expr_item):
		return AssumptionJustification.new()
	var justification = scratch_justifications.get(expr_item.get_unique_name())
	if justification != null:
		return justification
	return _get_done_justification(expr_item)


func _is_assumed(expr_item:ExprItem):
	for assumption in assumptions:
		if expr_item.compare(assumption):
			return true
	for import in imports:
		if imports[import].get_final_proof_box()._is_assumed(expr_item):
			return true
	if parent != null:
		return parent._is_assumed(expr_item)
	else:
		return false


func _get_done_justification(expr_item:ExprItem):
	var justification = done_justifications.get(expr_item.get_unique_name())
	if justification != null:
		return justification
	for import in imports:
		var ijustification = imports[import].get_final_proof_box()._get_done_justification(expr_item)
		if ijustification != null:
			return ijustification
	if parent != null:
		return parent._get_done_justification(expr_item)
	return null


func _get_parent_justification(expr_item:ExprItem):
	for import in imports:
		var justification = imports[import].get_final_proof_box().get_justification_for(expr_item)
		if justification != null:
			return justification
	if parent != null:
		return parent.get_justification_for(expr_item)
	return null
"""
