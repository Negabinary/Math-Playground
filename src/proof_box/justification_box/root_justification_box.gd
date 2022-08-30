extends AbstractJustificationBox
class_name RootJustificationBox


func _is_assumed(expr_item:ExprItem) -> bool:
	return false


func _missing_justification(expr_item:ExprItem) -> Justification:
	return null


func get_justifications_snapshot() -> JustificationMap:
	return justification_map.duplicate()


func is_child_of(other:AbstractJustificationBox) -> bool:
	if self == other:
		return true
	else:
		return false
