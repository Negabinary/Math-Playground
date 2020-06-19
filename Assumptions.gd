extends ScrollContainer

var ASSUMPTION_BOX := load("res://src/visual/assumption_box/AssumptionBox.tscn")

signal assumption_used
signal assumption_work_with
signal assumption_refine
signal equality_used


# Change all assumptions
func change_assumptions(proof_entries:Array): #Array<ProofEntry>
	_clear_assumptions()
	for proof_entry in proof_entries:
		for assumption in proof_entry.assumptions:
			save_assumption(assumption)


func _clear_assumptions():
	for a in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(a)
		a.queue_free()


func save_assumption(assumption:Statement):
	var assumption_box = ASSUMPTION_BOX.instance()
	$VBoxContainer.add_child(assumption_box)
	assumption_box.display_assumption(assumption, true)
	assumption_box.connect("assumption_conclusion_used", self, "_on_assumption_conclusion_used")
	assumption_box.connect("assumption_work_with", self, "_on_assumption_work_with")
	assumption_box.connect("expr_item_dropped_on_definition", self, "_on_assumption_refine")
	assumption_box.connect("use_equality", self, "_on_use_equality")


# Show which assumptions are relevant to selection
func mark_assumptions(selected_item:UniversalLocator):
	for assumption_box in $VBoxContainer.get_children():
		assumption_box.mark_assumptions(selected_item)


func mark_assumptions_from_top(statement:Statement, condition_idx:int):
	for assumption_box in $VBoxContainer.get_children():
		assumption_box.mark_assumptions_from_top(statement.get_conditions()[condition_idx])


func _on_assumption_conclusion_used(assumption, _index):
	assert (_index == 0)
	emit_signal("assumption_used", assumption)


func _on_assumption_work_with(assumption):
	emit_signal("assumption_work_with", assumption)


func _on_assumption_refine(assumption:Statement, definition:ExprItemType, locator:UniversalLocator):
	emit_signal("assumption_refine", assumption, definition, locator)


func _on_use_equality(equality:UniversalLocator):
	emit_signal("equality_used", equality)
