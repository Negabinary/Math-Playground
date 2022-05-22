class_name WrittenProofBoxBuilder

const WP_BOX = preload("res://ui/proof/written_proof_box/WPB2.tscn")

static func build(context:ProofBox, requirement:Requirement, selection_handler:SelectionHandler) -> Node:
	var node : Node = WP_BOX.instance()
	node.init(context, requirement, selection_handler)
	return node
