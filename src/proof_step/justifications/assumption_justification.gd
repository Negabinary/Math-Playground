extends Justification
class_name AssumptionJustification


func _init().():
	pass


func can_justify(expr_item:ExprItem):
	return true


func get_justification_text() -> String:
	return "ASSUMED"
