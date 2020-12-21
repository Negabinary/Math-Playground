extends ConfirmationDialog


func pop_up(proof_box:ProofBox):
	$ExprItemEdit.set_expr_item(null, proof_box)
	popup()


func _on_ExprItemEdit_expr_item_changed():
	pass # Replace with function body.
