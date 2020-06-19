extends Control


func _ready():
	$"HBoxContainer/TabContainer/From the Top".connect("condition_selected_from_top", self, "_on_condition_selected_from_top")
	$"HBoxContainer/TabContainer/From the Top".connect("condition_selected_from_top", self, "_on_condition_used_from_top")
	$"HBoxContainer/TabContainer/From the Top".connect("save_assumption", self, "_on_save_assumption")
	$HBoxContainer/Assumptions.connect("assumption_used", self, "_on_assumption_used")
	$HBoxContainer/Assumptions.connect("assumption_work_with", self, "_on_assumption_work_with")
	$"HBoxContainer/TabContainer/From the Bottom/Goals".connect("expr_item_selected", self, "_on_goal_item_selected")
	$"HBoxContainer/TabContainer/From the Bottom/ProofTree".connect("change_selected_proof_entry", self, "_on_change_selected_proof_entry")


func _on_change_selected_proof_entry(proof_entries:Array): #Array<ProofEntry>
	$"HBoxContainer/TabContainer/From the Bottom/Goals".show_expression(proof_entries[0].get_goal())
	$ColorRect/Buttons.update_buttons(proof_entries[0])
	$HBoxContainer/Assumptions.change_assumptions(proof_entries)


func _on_goal_item_selected(expr_locator:UniversalLocator):
	$HBoxContainer/Assumptions.mark_assumptions(expr_locator)


func _on_assumption_work_with(assumption):
	$HBoxContainer/TabContainer.current_tab = 1
	$"HBoxContainer/TabContainer/From the Top".work_with(assumption)


func _on_condition_selected_from_top(statement:Statement, condition_idx:int):
	$HBoxContainer/Assumptions.mark_assumptions_from_top(statement, condition_idx)


func _on_assumption_used(assumption:Statement):
	if $HBoxContainer/TabContainer.current_tab == 0:
		$"HBoxContainer/TabContainer/From the Bottom/ProofTree".use_assumption(assumption)
	else:
		$"HBoxContainer/TabContainer/From the Top".use_assumption(assumption)


func _on_save_assumption(assumption:Statement):
	$HBoxContainer/Assumptions.save_assumption(assumption)


func _on_equality_used(equality:UniversalLocator):
	var position = $"HBoxContainer/TabContainer/From the Bottom/Goals".get_selected()
	$"HBoxContainer/TabContainer/From the Bottom/ProofTree".use_equality(position, equality)
