extends Control


onready var ui_assumptions := $HBoxContainer/Context/Assumptions
onready var ui_goals := $HBoxContainer/Goals
onready var ui_proof_steps := $HBoxContainer/ProofSteps
onready var ui_buttons := $ColorRect/Buttons


func _set_up() -> void:
	var w2 = ExprItem.from_string("=>(=>(A,B),=>(=>(B,C),=>(A,C)))")
	w2 = ExprItem.from_string("=>(=>(A,=>(B,C)),=>(=>(A,B),C))")
	w2 = ExprItem.from_string("=>(=(A,B),=>(=>(P(A),P(C)),=>(P(B),P(C))))")
	var root_ps = ProofStep.new(w2)
	ui_proof_steps.display_proof(root_ps)


func _ready():
	_set_up()
	ui_proof_steps.connect("proof_step_selected", self, "_on_proof_step_selected")
	ui_goals.connect("expr_item_selected", self, "_on_goal_item_selected")


func _on_proof_step_selected(proof_step:ProofStep):
	ui_goals.show_expression(Statement.new(proof_step.get_conclusion().get_expr_item()))
	ui_assumptions.set_proof_step(proof_step)


func _on_goal_item_selected(expr_locator:UniversalLocator):
	ui_assumptions.set_locator(expr_locator.get_locator())
