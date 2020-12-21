extends VBoxContainer


func display_assumptions(proof_step:ProofStep):
	for child in get_children():
		remove_child(child)
	var definitions:Array = proof_step.get_requirements()[0].new_definitions
	for definition in definitions:
		var new_label = WrittenJustification.new()
		new_label.disabled = true
		new_label.set_text("THING " + definition.get_identifier())
		add_child(new_label)
	var assumptions:Array = proof_step.get_requirements()[0].new_assumptions
	for assumption in assumptions:
		var new_label = WrittenJustification.new()
		new_label.disabled = true
		new_label.set_text("ASSUME " + assumption.get_statement().to_string())
		add_child(new_label)
