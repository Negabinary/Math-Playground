extends VBoxContainer

var item

func initialise(item:ModuleItem2Theorem, selection_handler):
	self.item = item
	$"%Name".autostring = ExprItemAutostring.new(
		item.get_requirement().get_goal(),
		item.get_next_proof_box().get_parse_box()
	)
	$"%WrittenProof".display_proof(ProofStep.new(item.get_requirement(), item.get_context()))
	$"%Star".init(item.get_requirement().get_goal(), item.get_next_proof_box(), selection_handler)
	$"%Use".init(item.get_goal(), item.get_next_proof_box(), selection_handler)
	$"%Instantiate".init(item.get_goal(), item.get_next_proof_box(), selection_handler)
	$"%EqLeft".init(item.get_goal(), item.get_next_proof_box(), selection_handler, true)
	$"%EqRight".init(item.get_goal(), item.get_next_proof_box(), selection_handler)

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

func get_next_proof_box() -> SymmetryBox:
	return item.get_next_proof_box()
