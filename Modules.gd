extends ColorRect

signal request_proof
signal proof_step_created

const MODULE := preload("res://src/visual/module/Module.tscn")

onready var module_loader := ModuleLoader.new()

var selection_handler


func initialise(selection_handler:SelectionHandler):
	self.selection_handler = selection_handler
	#for module_name in ["test","typing","trig","real_test","real","the_set_of_all_sets","functional","list","current_module","peano", "boolean", "small_numbers","addition"]:
	#for module_name in ["trig","real_test","real"]:
	#for module_name in ["bool/bool_type", "bool/bool_and", "bool/bool_or", "bool/de_morgan"]:
	#for module_name in ["2p2e4","small_numbers","addition","peano"]:
	for module_name in ["pres/peano","pres/2nat"]:
		add_module(module_loader.get_module(module_name), module_name, selection_handler)


func add_module(module:MathModule, mname:String, selection_handler:SelectionHandler) -> void:
	var module_box : Node = MODULE.instance()
	module_box.set_selection_handler(selection_handler)
	module_box.load_module(module, mname)
	$ScrollContainer/MarginContainer/HBoxContainer.add_child(module_box)
	$ScrollContainer/MarginContainer/HBoxContainer.move_child(module_box, module_box.get_index() - 1)
	module_box.connect("request_to_prove", self, "_on_proof_request")
	module_box.connect("proof_step_created", self, "_on_proof_step_created")
	

func _on_proof_request(proof_step:ProofStep, module:MathModule):
	emit_signal("request_proof", proof_step)

func _on_proof_step_created(proof_step:ProofStep):
	emit_signal("proof_step_created", proof_step)



func _on_WindowDialog_confirmed():
	var module_name = $ScrollContainer/MarginContainer/HBoxContainer/VBoxContainer/Button2/WindowDialog/Label2.text
	add_module(module_loader.get_module(module_name), module_name, selection_handler)


func _on_CodeDialog_confirmed():
	var module_name = $ScrollContainer/MarginContainer/HBoxContainer/VBoxContainer/Button/CodeDialog/VBoxContainer/Label3.text
	var module_content = $ScrollContainer/MarginContainer/HBoxContainer/VBoxContainer/Button/CodeDialog/VBoxContainer/Label2.text
	add_module(module_loader.get_module(module_name, module_content), module_name, selection_handler)
