extends ColorRect


func enter_proof_mode(proof:ProofStep):
	$TabContainer/Proof._set_proof(proof)
	$TabContainer.current_tab = 1
