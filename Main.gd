extends Control


func _on_change_selected_proof_entry(proof_entries:Array): #Array<ProofEntry>
	$HBoxContainer/Goals.show_expression(proof_entries[0].get_goal())
	$ColorRect/Buttons.update_buttons(proof_entries[0])
	$HBoxContainer/Assumptions.change_assumptions(proof_entries)


func _on_goal_item_selected(expr_locator:UniversalLocator):
	$HBoxContainer/Assumptions.mark_assumptions(expr_locator)
