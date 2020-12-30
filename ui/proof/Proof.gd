extends Control

onready var ui_assumptions := $VSplitContainer/VSplitContainer/Proof/Context/VBoxContainer/Assumptions
onready var ui_written_proof := $VSplitContainer/VSplitContainer/Proof/ColorRect/ScrollContainer/MarginContainer/PanelContainer/WrittenProof
onready var ui_modules := $VSplitContainer/Modules

var root_ps : ProofStep

func _set_up() -> void:
	var w2 = ExprItemBuilder.from_string("For all(A,For all(B,For all(C,=>(=>(A,B),=>(=>(B,C),=>(A,C))))))", GlobalTypes.PROOF_BOX)
	root_ps = ProofStep.new(w2)
	ui_written_proof.display_proof(root_ps)


func _ready():
	_set_up()
	ui_modules.initialise($SelectionHandler)
	$SelectionHandler.connect("proof_step_changed", self, "_on_proof_step_selected")
	$SelectionHandler.connect("locator_changed", self, "_on_goal_item_selected")
	$SelectionHandler.connect("proof_changed", self, "_set_proof")


func _on_proof_step_selected(proof_step:ProofStep):
	ui_assumptions.set_proof_step(proof_step)


func _on_goal_item_selected(expr_locator:Locator):
	ui_assumptions.set_locator(expr_locator)


func _set_proof(proof_step:ProofStep):
	ui_modules.display_modules(proof_step)
	ui_written_proof.display_proof(proof_step)
	_on_proof_step_selected(proof_step)
