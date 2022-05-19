class_name Justification


signal updated


# GETTERS =================================================

func get_requirements_for(expr_item:ExprItem):
	return null


func get_options_for(expr_item:ExprItem):
	return []


func get_justification_text():
	return "USING SOMETHING OR OTHER"


# OPTIONS ===============================================


class Option:
	func get_option_name() -> String:
		return ""


class BooleanOption extends Option:
	func get_disabled() -> bool:
		return false
	
	func get_value() -> bool:
		return false
	
	func set_value(x:bool):
		pass


class MathOption extends Option:
	func get_proof_box() -> bool:
		return false
	
	func set_proof_box(x:bool):
		pass


class LabelOption extends Option:
	var text : String
	var err : bool
	
	func _init(text:String, err=false):
		self.text = text
		self.err = err
	
	func get_text():
		return text
	
	func get_is_err():
		return err

enum OPTION_TYPES {
	BOOLEAN,
	NAME,
	MATH
}
