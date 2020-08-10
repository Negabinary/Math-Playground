extends PanelContainer


signal dependency_selected


func _toggle_visibility():
	if visible:
		hide()
	else:
		show()


func display_requirements(proof_step:ProofStep, wp_box:Node, req_id:int):
	for child in $Requirements.get_children():
		$Requirements.remove_child(child)
	var requirements := proof_step.get_requirements()
	for requirement in requirements:
		var new_label = WrittenJustification.new()
		new_label.set_text(requirement.get_statement().to_string(), ">" if requirement == requirements[req_id] else ("" if requirement.is_proven() else "!"))
		$Requirements.add_child(new_label)
		new_label.connect("pressed", self, "emit_signal", ["dependency_selected", requirements.find(requirement)])
		new_label.connect("pressed", self, "display_requirements", [proof_step, wp_box, requirements.find(requirement)])
