extends ScrollContainer

var ASSUMPTION_BOX := load("res://src/visual/assumption_box/AssumptionBox.tscn")

var proof_step : ProofStep
var locator : Locator


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
	for assumption in proof_step.get_assumptions():
		save_assumption(assumption)


func save_assumption(assumption:ProofStep):
	var assumption_box = ASSUMPTION_BOX.instance()
	$VBoxContainer.add_child(assumption_box)
	assumption_box.display_assumption(assumption)
	assumption_box.connect("assumption_conclusion_used", self, "_on_assumption_conclusion_used")
	assumption_box.connect("expr_item_dropped_on_definition", self, "_on_assumption_refine")
	assumption_box.connect("use_equality", self, "_on_use_equality")


func _on_assumption_conclusion_used(assumption:ProofStep, _index):
	assert (_index == 0)
	proof_step.justify_with_modus_ponens(assumption)


func _on_use_equality(assumption:ProofStep, equality:UniversalLocator):
	proof_step.justify_with_equality(assumption, locator, equality.get_locator())


func _on_assumption_refine(assumption:Statement, definition:ExprItemType, locator:UniversalLocator):
	pass
