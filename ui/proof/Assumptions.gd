extends ScrollContainer

var ASSUMPTION_BOX := load("res://ui/proof/assumption_box/AssumptionBox.tscn")

var proof_step : ProofStep
var locator : Locator
onready var selection_handler:SelectionHandler = $"../../../..//SelectionHandler"


func _ready():
	selection_handler.connect("proof_step_changed", self, "_on_proof_step_selected")
	selection_handler.connect("locator_changed", self, "_on_goal_item_selected")
	selection_handler.connect("proof_changed", self, "_set_proof")


func _on_proof_step_selected(proof_step:ProofStep):
	set_proof_step(proof_step)


func _on_goal_item_selected(expr_locator:Locator):
	set_locator(expr_locator)


func set_locator(new_location:Locator) -> void:
	set_proof_step(proof_step, new_location)


func set_proof_step(new_proof_step:ProofStep, new_location:Locator=null) -> void:
	if new_location == null:
		new_location = new_proof_step.get_conclusion()
	if proof_step != new_proof_step:
		proof_step = new_proof_step
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
	for assumption in proof_step.get_proof_box().get_starred_assumptions():
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
			var refined_ps = ProofStep.new(assumption.get_statement().deep_replace_types(matching).as_expr_item())
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
