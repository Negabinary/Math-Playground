class_name WrittenProofBoxBuilder

const WP_BOX = preload("res://ui/proof/written_proof_box/WrittenProofBox.tscn")
const WP_MISSING = preload("res://ui/proof/written_proof_box/WPBMissing.tscn")
const WP_IMPLICATION = preload("res://ui/proof/written_proof_box/WPBImplication.tscn")

static func build(proof_step:ProofStep, selection_handler:SelectionHandler) -> Node:
	var node : Node
	if proof_step.justification is MissingJustification:
		node = WP_MISSING.instance()
	elif proof_step.justification is ProofStep.ImplicationJustification:
		node = WP_IMPLICATION.instance()
	else:
		node= WP_BOX.instance()
	node.initialise(proof_step, selection_handler)
	return node
