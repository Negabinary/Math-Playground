class_name Justification


signal justified


var requirements := [] #<ProofStep>     ProofStep also stores the box?
var PROOF_STEP = load("res://src/proof_step/proof_step.gd")

enum OPTION_TYPES {
	BOOLEAN,
	NAME,
	MATH
}


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


func get_options() -> Array:
	return []


func get_option_type(option_idx:int) -> int:
	return OPTION_TYPES.BOOLEAN


func get_option_proof_box(option_idx:int):
	return null


func set_option(option_idx:int, value) -> void:
	pass


func get_option(option_idx:int):
	return null


func get_option_disabled(option_idx:int) -> bool:
	return false


func get_justification_text():
	return "USING SOMETHING OR OTHER"
