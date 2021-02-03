extends WPBParent
class_name WrittenProofBox

var ui_active_dependency
var ui_justification_label
var ui_requirements


func initialise(proof_step:ProofStep, selection_handler:SelectionHandler, active_dependency_id:=-1):
	.initialise(proof_step, selection_handler, active_dependency_id)
	
	$MarginContainer/Options/VBoxContainer/HBoxContainer/UnproveButton.connect("pressed", self, "_on_unprove")
	
	var requirements := proof_step.get_requirements()
	if active_dependency_id == -1:
		active_dependency_id = requirements.size() - 1
	_update_active_dependency(active_dependency_id)
	
	_update_justification_label()


func _find_ui_elements():
	ui_active_dependency = $ActiveDependency
	ui_justification_label = $JustificationLabel
	ui_requirements = $MarginContainer/Options
	._find_ui_elements()


func _update_active_dependency(new_active_dependency_id):
	active_dependency_id = new_active_dependency_id
	
	# Remove previous dependency
	if active_dependency != null:
		active_dependency.disconnect("justified", self, "_update_active_dependency")
		ui_active_dependency.remove_child(ui_active_dependency.get_child(0))
	
	# Add new dependency
	if proof_step.get_requirements().size() != 0:
		active_dependency = proof_step.get_requirements()[active_dependency_id]
		var wp_box = load("res://ui/proof/written_proof_box/wp_box_builder.gd").build(active_dependency, selection_handler)
		ui_active_dependency.add_child(wp_box)
		active_dependency.connect("justified", self, "_update_active_dependency", [new_active_dependency_id])
	else:
		active_dependency = null
	
	_update_justification_box()


func _on_selected_proof_step_changed(new_proof_step):
	._on_selected_proof_step_changed(new_proof_step)
	_update_justification_label()

func _update_justification_label():
	ui_justification_label.disabled = proof_step.get_requirements().size() == 0
	var icon = "" if _conditions_met() else "!"
	ui_justification_label.set_text(proof_step.get_justification_text(), icon)


func _update_justification_box():
	ui_requirements.display_justification(proof_step.get_justification(), active_dependency_id)
	ui_requirements.connect("dependency_selected", self, "_update_active_dependency")


func _on_unprove():
	proof_step.justify(MissingJustification.new())
