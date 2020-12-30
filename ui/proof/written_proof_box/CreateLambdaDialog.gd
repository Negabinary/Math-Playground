extends ConfirmationDialog

func pop_up(proof_step:ProofStep, locator:Locator) -> void:
	$CreateLambda.setup(proof_step, locator)
	get_ok().disabled = true
	popup_centered()

func _on_CreateLambda_update():
	get_ok().disabled = !$CreateLambda.is_valid()
