extends Control


onready var ui_assumptions := $HBoxContainer/Assumptions
onready var ui_goals := $HBoxContainer/Goals
onready var ui_proof_tree := $HBoxContainer/ProofTree
onready var ui_buttons := $ColorRect/Buttons


func _ready():
	ui_assumptions.connect("assumption_used", self, "_on_assumption_used")
	ui_goals.connect("expr_item_selected", self, "_on_goal_item_selected")
	ui_proof_tree.connect("change_selected_proof_entry", self, "_on_change_selected_proof_entry")


func _on_change_selected_proof_entry(proof_entries:Array): #Array<ProofEntry>
	ui_goals.show_expression(proof_entries[0].get_goal())
	ui_buttons.update_buttons(proof_entries[0])
	ui_assumptions.change_assumptions(proof_entries)


func _on_goal_item_selected(expr_locator:UniversalLocator):
	ui_assumptions.mark_assumptions(expr_locator)


func _on_assumption_used(assumption:Statement):
	ui_proof_tree.use_assumption(assumption)


func _on_equality_used(equality:UniversalLocator):
	var position = ui_goals.get_selected()
	ui_proof_tree.use_equality(position, equality)
