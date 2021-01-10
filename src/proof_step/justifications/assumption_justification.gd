extends Justification
class_name AssumptionJustification


var proof_box


func _init(proof_box):
	self.proof_box = proof_box


func _verify(proof_step):
	return proof_box.check_assumption(proof_step)


func get_justification_text() -> String:
	match proof_box.get_level():
		0:
			return "ALWAYS ASSUMED"
		1:
			return "ASSUMED IN MODULE"
		2:
			return "ASSUMED IN MODULE"
		_:
			return "ASSUMED"
