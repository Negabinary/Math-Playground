extends Justification
class_name MissingJustification 

func _init():
	requirements = []

func _verify(_proof_step) -> bool:
	return false

func get_justification_text():
	return "MISSING JUSTIFICATION"
