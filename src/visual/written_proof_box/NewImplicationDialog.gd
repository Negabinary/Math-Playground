extends ConfirmationDialog


func pop_up(proof_box:ProofBox):
	$CenterContainer/ExprItemEdit.set_expr_item(null, proof_box)
	get_ok().disabled = true
	popup_centered()


func _on_ExprItemEdit_expr_item_changed():
	get_ok().disabled = $CenterContainer/ExprItemEdit.has_holes()
