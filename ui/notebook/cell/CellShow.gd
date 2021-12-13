extends VBoxContainer

var item

func initialise(item:ModuleItem2Theorem):
	self.item = item
	$HBoxContainer3/Name.text = item.get_ps().get_expr_item().to_string()
	$Proof/WrittenProof.display_proof(item.get_ps())

func serialise():
	return item.serialise()

func deserialise(item, proof_box):
	initialise(ModuleItem2Theorem.new(
		proof_box, 
		ExprItemBuilder.from_string(item.expr, proof_box),
		item.proof
	))
