extends Justification
class_name ReflexiveJustification


func _init():
	requirements = []


func get_justification_text():
	return "BECAUSE ANYTHING EQUALS ITSELF"


func _verify_expr_item(expr_item:ExprItem) -> bool:
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return false
	else:
		return expr_item.get_child(0).compare(expr_item.get_child(1))
