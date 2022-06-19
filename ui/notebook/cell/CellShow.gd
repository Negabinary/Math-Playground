extends VBoxContainer

var item

func initialise(item:ModuleItem2Theorem):
	self.item = item
	$HBoxContainer3/Name.text = item.get_requirement().get_goal().to_string()
	$Proof/WrittenProof.display_proof(ProofStep.new(item.get_requirement(), item.get_context()))

func serialise():
	return item.serialise()

func deserialise(item, proof_box, version):
	initialise(ModuleItem2Theorem.new(
		proof_box, 
		ExprItemBuilder.deserialize(item.expr, proof_box.get_parse_box()),
		item.proof,
		version
	))
