extends ScrollContainer

var ASSUMPTION_BOX := load("res://ui/proof/assumption_box/AssumptionBox.tscn")

var goal : ExprItem
var proof_box : ProofBox
var locator : Locator
onready var selection_handler:SelectionHandler = $"../../../..//SelectionHandler"


func _ready():
	selection_handler.connect("locator_changed", self, "_on_goal_item_selected")


func _on_goal_item_selected(expr_locator:Locator):
	set_proof_step(selection_handler.get_goal(), selection_handler.get_inner_proof_box(), expr_locator)


func set_proof_step(goal:ExprItem, proof_box:ProofBox, new_location:Locator=null) -> void:
	if new_location == null:
		new_location = Statement.new(goal).get_conclusion()
	if not self.goal.compare(goal) or self.proof_box != proof_box:
		self.goal = goal
		self.proof_box = proof_box
		_update_assumptions()
	locator = new_location
	_mark_assumptions()


func _mark_assumptions():
	for assumption_box in $VBoxContainer.get_children():
		assumption_box.update_context(proof_step, locator)


func _clear_assumptions():
	for a in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(a)
		a.queue_free()


func _update_assumptions() -> void:
	_clear_assumptions()
	for assumption in proof_step.get_proof_box().get_all_assumptions():
		save_assumption(assumption)


func save_assumption(assumption:ProofStep):
	var assumption_box = ASSUMPTION_BOX.instance()
	$VBoxContainer.add_child(assumption_box)
	assumption_box.display_assumption(assumption, selection_handler)
	assumption_box.connect("assumption_conclusion_used", self, "_on_assumption_conclusion_used")
	assumption_box.connect("proof_step_created", self, "_on_proof_step_created")
	assumption_box.connect("use_equality", self, "_on_use_equality")


func _on_assumption_conclusion_used(assumption:ProofStep, _index):
	assert (_index == 0)
	if locator.get_expr_item().compare(assumption.get_statement().get_conclusion().get_expr_item()):
		if assumption.get_statement().get_conditions().size() == 0:
			proof_step.justify_with_assumption(proof_step.get_proof_box())
		else:
			proof_step.justify_with_modus_ponens(assumption)
	else:
		var matching := {}
		for definition in assumption.get_statement().get_definitions():
			matching[definition] = "*"
		if assumption.get_statement().get_conclusion().get_expr_item().is_superset(locator.get_expr_item(), matching):
			var refined_ps = ProofStep.new(assumption.get_expr_item().deep_replace_types(matching))
			refined_ps.justify_with_specialisation(assumption, matching)
			proof_step.justify_with_modus_ponens(refined_ps)
		else:
			assert(false) # ERROR


func _on_use_equality(assumption:ProofStep, index:int):
	proof_step.justify_with_equality(assumption, 1-index, index, locator)


func _on_proof_step_created(refined_ps:ProofStep):
	save_assumption(refined_ps)


func _on_Modules_proof_step_created(refined_ps:ProofStep):
	save_assumption(refined_ps)
