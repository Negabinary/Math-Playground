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
	$"%WrittenProof".display_proof(ProofStep.new(item.get_requirement(), item.get_context()))
	$"%Star".init(item.get_requirement().get_goal(), item.get_next_proof_box(), selection_handler)
	$"%Use".init(item.get_goal(), item.get_next_proof_box(), selection_handler)
	$"%Instantiate".init(item.get_goal(), item.get_next_proof_box(), selection_handler)
	$"%EqLeft".init(item.get_goal(), item.get_next_proof_box(), selection_handler, true)
	$"%EqRight".init(item.get_goal(), item.get_next_proof_box(), selection_handler)

func _update_text():
	$"%Name".text = autostring.get_string()

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

func take_type_census(census:TypeCensus) -> TypeCensus:
	item.take_type_census(census)
	return $"%WrittenProof".take_type_census(census)
