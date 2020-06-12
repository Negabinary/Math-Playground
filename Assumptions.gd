extends ScrollContainer

var ASSUMPTION_BOX := load("res://src/visual/assumption_box/AsumptionBox.tscn")

signal assumption_used

# Change all assumptions
func change_assumptions(proof_entries:Array): #Array<ProofEntry>
	_clear_assumptions()
	for proof_entry in proof_entries:
		for assumption in proof_entry.assumptions:
			var assumption_box = ASSUMPTION_BOX.instance()
			$VBoxContainer.add_child(assumption_box)
			assumption_box.display_assumption(assumption)
			assumption_box.connect("assumption_used", self, "_on_assumption_used")


func _clear_assumptions():
	for a in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(a)
		a.queue_free()


# Show which assumptions are relevant to selection
func mark_assumptions(selected_item:Locator):
	for assumption_box in $VBoxContainer.get_children():
		assumption_box.mark_assumptions(selected_item)


func _on_assumption_used(assumption):
	emit_signal("assumption_used", assumption)
