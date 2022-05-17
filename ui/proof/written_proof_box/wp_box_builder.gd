class_name WrittenProofBoxBuilder

const WP_BOX = preload("res://ui/proof/written_proof_box/WrittenProofBox.tscn")
const WP_MISSING = preload("res://ui/proof/written_proof_box/WPBMissing.tscn")
const WP_IMPLICATION = preload("res://ui/proof/written_proof_box/WPBImplication.tscn")

static func build(requirement:Requirement, selection_handler:SelectionHandler) -> Node:
	var node : Node
	if requirement.get_or_create_justification() is MissingJustification:
		node = WP_MISSING.instance()
	elif requirement.get_or_create_justification() is ImplicationJustification:
		node = WP_IMPLICATION.instance()
	else:
		node= WP_BOX.instance()
	node.initialise(requirement, selection_handler)
	return node
