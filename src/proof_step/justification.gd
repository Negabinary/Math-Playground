class_name Justification


signal updated


# GETTERS =================================================

func get_requirements_for(expr_item:ExprItem):
	return []


# OPTIONS ===============================================


enum OPTION_TYPES {
	BOOLEAN,
	NAME,
	MATH
}


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
