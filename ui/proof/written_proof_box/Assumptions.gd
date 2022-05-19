extends VBoxContainer
class_name Assumptions

func display_assumptions(requirement:Requirement):
	for child in get_children():
		remove_child(child)
	var definitions:Array = requirement.get_definitions()
	for definition in definitions:
		var new_label = WrittenJustification.new()
		new_label.disabled = true
		new_label.set_text("THING " + definition.get_identifier())
		add_child(new_label)
	var assumptions:Array = requirement.get_assumptions()
	for assumption in assumptions:
		var new_label = WrittenJustification.new()
		new_label.disabled = true
		new_label.set_text("ASSUME " + assumption.to_string())
		add_child(new_label)
