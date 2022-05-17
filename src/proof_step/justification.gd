class_name Justification

signal proven
signal unproven


var requirements := [] #<Requirement>
var PROOF_STEP = load("res://src/proof_step/proof_step.gd")
var is_proven : bool

func _init(reqs:Array):
	for requirement in requirements:
		requirement.connect("proven", self, "_on_req_changed")
		requirement.connect("unproven", self, "_on_req_changed")


# GETTERS =================================================

func get_requirements() -> Array: #<Requirement>
	return requirements


# SETTERS =================================================

func replace_requirements(new_reqs) -> void: #<Requirement>
	for requirement in requirements:
		requirement.disconnect("proven", self, "_on_req_changed")
		requirement.disconnect("unproven", self, "_on_req_changed")
	requirements = new_reqs
	for requirement in requirements:
		requirement.connect("proven", self, "_on_req_changed")
		requirement.connect("unproven", self, "_on_req_changed")


# CORRECTNESS =============================================


# TODO: Prevent Cycles
func _on_req_changed():
	var prev_proven := is_proven
	is_proven = true
	for requirement in requirements:
		if not requirement.is_proven():
			is_proven = false
	if is_proven and not prev_proven:
		emit_signal("proven")
	elif not is_proven and prev_proven:
		emit_signal("unproven")


func can_prove(expr_item:ExprItem) -> bool:
	# VIRTUAL DEFAULT
	return is_proven and can_justify(expr_item)


func can_justify(expr_item:ExprItem) -> bool:
	#VIRTUAL DEFAULT
	return false


# OLD =====================================================





func _verify_requirements() -> bool:
	for requirement in requirements:
		if !requirement.is_proven():
			return false
	return true


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
