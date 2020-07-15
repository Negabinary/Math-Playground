class_name JustificationBoxBuilder

const UNIPLEMENTED_JUSTIFICATION = preload("res://src/visual/justification_box/UniplementedJustification.tscn")
const MISSING_JUSTIFICATION = preload("res://src/visual/justification_box/MissingJustification.tscn")
const MODUS_PONENS_JUSTIFICATION = preload("res://src/visual/justification_box/ModusPonensJustification.tscn")
const EQUALITY_JUSTIFICATION = preload("res://src/visual/justification_box/EqualityJustification.tscn")
const IMPLICATION_JUSTIFICATION = preload("res://src/visual/justification_box/ImplicationJustification.tscn")
const ASSUMED_JUSTIFIACTION = preload("res://src/visual/justification_box/AssumedJustification.tscn")


static func build(proof_step:ProofStep, main) -> Node:
	var node : Node
	if proof_step.justification is ProofStep.MissingJustification:
		node = MISSING_JUSTIFICATION.instance()
	elif proof_step.justification is ProofStep.ModusPonensJustificaiton:
		node = MODUS_PONENS_JUSTIFICATION.instance()
	elif proof_step.justification is ProofStep.EqualityJustification:
		node = EQUALITY_JUSTIFICATION.instance()
	elif proof_step.justification is ProofStep.ImplicationJustification:
		node = IMPLICATION_JUSTIFICATION.instance()
	elif proof_step.justification is ProofStep.AssumedJustification:
		node = ASSUMED_JUSTIFIACTION.instance()
	else:
		node = UNIPLEMENTED_JUSTIFICATION.instance()
	node.initialise(proof_step, main)
	return node
