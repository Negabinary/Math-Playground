extends Container

signal request_to_prove
signal proof_step_created

var module : MathModule
var module_name : String
var selection_handler : SelectionHandler
const ASSUMPTION_BOX = preload("res://ui/proof/assumption_box/AssumptionBox.tscn")

var ui_assumptions

func set_selection_handler(selection_handler:SelectionHandler):
	self.selection_handler = selection_handler
	selection_handler.connect("locator_changed", self, "_on_locator_changed")

func load_module(module:MathModule, name:String):
	module_name = name
	ui_assumptions = $ScrollContainer/Control/VBoxContainer/ModuleAssumptions
	
	$ScrollContainer/Control/VBoxContainer/ModuleName.text = name
	
	self.module = module
	for proof_step in module.get_proof_steps():
		var assumption_box = ASSUMPTION_BOX.instance()
		ui_assumptions.add_child(assumption_box)
		assumption_box.display_assumption(proof_step, selection_handler)
		assumption_box.connect("request_to_prove", self, "emit_signal", ["request_to_prove", ProofStep.new(proof_step.get_statement().as_expr_item(), proof_step.get_proof_box()), module])
		assumption_box.connect("proof_step_created", self, "_on_proof_step_created")
		assumption_box.connect("assumption_conclusion_used", self, "_on_assumption_conclusion_used")
		assumption_box.connect("use_equality", self, "_on_assumption_equality_used")
		
	var definitions := module.get_definitions()
	var string
	if definitions.size() == 0:
		string = "(No Definitions)"
	else:
		string = "Definitions: "
		for d in definitions:
			string += "\n - " + PoolStringArray(([d.to_string()])).join(": ")
	$ScrollContainer/Control/VBoxContainer/ModuleDefinitions.text = string
	
	var requirements := module.get_requirements()
	if requirements.size() == 0:
		string = "(No Requirements)"
	else:
		string = "Requirements: "
		for r in requirements:
			string += "\n - " + r.get_name()
	$ScrollContainer/Control/VBoxContainer/ModuleRequirements.text = string


func _on_proof_step_created(proof_step:ProofStep):
	emit_signal("proof_step_created", proof_step)

func _on_locator_changed(locator:Locator):
	for assumption_box in $ScrollContainer/Control/VBoxContainer/ModuleAssumptions.get_children():
		assumption_box.update_context(selection_handler.get_proof_step(), locator)

func _on_assumption_conclusion_used(assumption:ProofStep, _index:int):
	selection_handler.get_proof_step().justify_with_modus_ponens(assumption)

func _on_assumption_equality_used(assumption:ProofStep, index:int):
	selection_handler.get_proof_step().justify_with_equality(assumption, 1-index, index, selection_handler.get_locator())
