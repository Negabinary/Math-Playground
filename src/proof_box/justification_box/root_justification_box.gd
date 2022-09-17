extends AbstractJustificationBox
class_name RootJustificationBox


func _is_assumed(expr_item:ExprItem) -> bool:
	return false


func get_justifications_snapshot():
	return justification_map.duplicate()


func is_child_of(other:AbstractJustificationBox) -> bool:
	if self == other:
		return true
	else:
		return false
