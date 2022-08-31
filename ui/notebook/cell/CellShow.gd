extends VBoxContainer

var item
var autostring : Autostring

func initialise(item:ModuleItem2Theorem, selection_handler):
	self.item = item
	autostring = ExprItemAutostring.new(
		item.get_requirement().get_goal(),
		item.get_next_proof_box().get_parse_box()
	)
	autostring.connect("updated", self, "_update_text")
	_update_text()
	$HBoxContainer2/Proof/ScrollContainer/WrittenProof.display_proof(ProofStep.new(item.get_requirement(), item.get_context()))
	
	$HBoxContainer4/Use.init(item.get_goal(), item.get_next_proof_box(), selection_handler)
	$HBoxContainer4/Instantiate.init(item.get_goal(), item.get_next_proof_box(), selection_handler)
	$HBoxContainer4/EqLeft.init(item.get_goal(), item.get_next_proof_box(), selection_handler, true)
	$HBoxContainer4/EqRight.init(item.get_goal(), item.get_next_proof_box(), selection_handler)

func _update_text():
	$HBoxContainer3/Name.text = autostring.get_string()

func serialise():
	return item.serialise()

func deserialise(item, proof_box, version, selection_handler:SelectionHandler):
	initialise(
		ModuleItem2Theorem.new(
			proof_box, 
			ExprItemBuilder.deserialize(item.expr, proof_box.get_parse_box()),
			item.proof,
			version
		),
		selection_handler
	)
