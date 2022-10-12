extends VBoxContainer

var item
var proof_step : ProofStep

func initialise(item:ModuleItem2Theorem, selection_handler):
	self.item = item
	$"%Name".autostring = ExprItemAutostring.new(
		item.get_requirement().get_goal(),
		item.get_next_proof_box().get_parse_box()
	)
	proof_step = ProofStep.new(item.get_requirement(), item.get_context())
	$"%FinishedIndicator".connect("pressed", self, "_on_indicator_clicked")
	$"%WrittenProof".display_proof(proof_step)
	$"%Star".init(item.get_requirement().get_goal(), item.get_next_proof_box(), selection_handler)
	$"%Use".init(item.get_goal(), item.get_next_proof_box(), selection_handler)
	$"%Instantiate".init(item.get_goal(), item.get_next_proof_box(), selection_handler)
	$"%EqLeft".init(item.get_goal(), item.get_next_proof_box(), selection_handler, true)
	$"%EqRight".init(item.get_goal(), item.get_next_proof_box(), selection_handler)
	proof_step.connect("proof_status", self, "_update_finished_indicator")
	_update_finished_indicator()


func _update_finished_indicator():
	if proof_step.is_proven():
		$"%FinishedIndicator".disabled = true
		$"%FinishedIndicator".flat = true
		$"%FinishedIndicator".theme_type_variation = "OptionTicked"
	else:
		$"%FinishedIndicator".disabled = false
		$"%FinishedIndicator".flat = false
		$"%FinishedIndicator".theme_type_variation = "OptionWarn"


func _on_indicator_clicked():
	proof_step.show_next_unproven()
	$"%WrittenProof".take_selection_for_top()


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
