extends ColorRect

signal request_proof
signal proof_step_created

const MODULE := preload("res://src/visual/module/Module.tscn")

onready var module_loader := ModuleLoader.new()



func initialise(selection_handler:SelectionHandler):
	for module_name in ["the_set_of_all_sets","functional","list","current_module","peano", "boolean", "small_numbers","addition"]:
		add_module(module_loader.get_module(module_name), module_name, selection_handler)


func add_module(module:MathModule, mname:String, selection_handler:SelectionHandler) -> void:
	var module_box : Node = MODULE.instance()
	module_box.set_selection_handler(selection_handler)
	module_box.load_module(module, mname)
	$ScrollContainer/MarginContainer/HBoxContainer.add_child(module_box)
	module_box.connect("request_to_prove", self, "_on_proof_request")
	module_box.connect("proof_step_created", self, "_on_proof_step_created")


func _on_proof_request(proof_step:ProofStep, module:MathModule):
	emit_signal("request_proof", proof_step)

func _on_proof_step_created(proof_step:ProofStep):
	emit_signal("proof_step_created", proof_step)
