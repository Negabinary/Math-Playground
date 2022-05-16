extends Justification
class_name AssumptionJustification


var proof_box


func _init(proof_box):
	self.proof_box = proof_box


func _verify(proof_step):
	return true


func get_justification_text() -> String:
	return "ASSUMED"
