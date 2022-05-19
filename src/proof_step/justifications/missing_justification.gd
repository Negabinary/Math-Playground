extends Justification
class_name MissingJustification 

func can_prove(x) -> bool:
	return false

func can_justify(x) -> bool:
	return true

func get_justification_text():
	return "MISSING JUSTIFICATION"
