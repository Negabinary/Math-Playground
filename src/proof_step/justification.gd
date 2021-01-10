class_name Justification


signal justified


var requirements : Array #<ProofStep>     ProofStep also stores the box?
var PROOF_STEP = load("res://src/proof_step/proof_step.gd")


func _init():
	for requirement in requirements:
		requirement.connect("justified", self, "_on_justified")


func _on_justified():
	emit_signal("justified")


func is_proven() -> bool:
	return true


func get_requirements() -> Array: #<ProofStep>
	return requirements


func verify(proof_step) -> bool:
	return _verify(proof_step) && _verify_requirements()


func _verify(proof_step) -> bool:
	return _verify_expr_item(proof_step.get_statement().as_expr_item())


func _verify_expr_item(expr_item:ExprItem) -> bool:
	return is_proven()


func _verify_requirements() -> bool:
	for requirement in requirements:
		if !requirement.is_proven():
			return false
	return true


func get_justification_text():
	return "USING SOMETHING OR OTHER"
