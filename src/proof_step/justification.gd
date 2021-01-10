class_name Justification


var requirements : Array #<ProofStep>     ProofStep also stores the box?
var PROOF_STEP = load("res://src/proof_step/proof_step.gd")


func is_proven() -> bool:
	return true


func get_requirements() -> Array: #<ProofStep>
	return requirements


func verify(statement:ExprItem) -> bool:
	return _verify(statement) && _verify_requirements()


func _verify(statement:ExprItem) -> bool:
	return is_proven()


func _verify_requirements() -> bool:
	for requirement in requirements:
		if !requirement.is_proven():
			return false
	return true
