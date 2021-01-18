extends Node
class_name JustificationBuilder


static func conditional_instantiation_justify(justified:ProofStep, cond_exist:ProofStep):
	assert (cond_exist.get_statement().get_definitions().size() == 0)
	assert (cond_exist.get_conclusion().get_expr_item().get_type() == GlobalTypes.EXISTS)
	
	var uncond_exist : ProofStep
	if cond_exist.get_statement().get_conditions().size() == 0:
		uncond_exist = cond_exist
	else:
		uncond_exist = ProofStep.new(
			cond_exist.get_statement().get_conclusion().get_expr_item(),
			justified.get_proof_box(),
			MissingJustification.new()
		)
		uncond_exist.justify_with_modus_ponens(cond_exist)
	
	justified.justify_with_instantiation(uncond_exist)


static func custom_implication(proof_step:ProofStep, custom:ExprItem):
	var proof_step_ei = proof_step.get_statement().as_expr_item()
	var new_ei = ExprItem.new(GlobalTypes.IMPLIES, [custom, proof_step_ei])
	var new_ps = ProofStep.new(
		new_ei,
		proof_step.get_proof_box(),
		MissingJustification.new()
	)
	proof_step.justify_with_modus_ponens(new_ps)
