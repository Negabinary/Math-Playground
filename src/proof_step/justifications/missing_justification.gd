extends Justification
class_name MissingJustification 

func _init():
	requirements = []

func _verify(_expr_item:ExprItem) -> bool:
	return false

func get_justification_text():
	return "MISSING JUSTIFICATION"
