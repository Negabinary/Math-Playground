extends VBoxContainer
class_name Assumptions

var requirement:Requirement

func display_assumptions(requirement:Requirement):
	self.requirement = requirement
	for definition in requirement.get_definitions():
		definition.connect("renamed", self, "_update_assumptions")
	_update_assumptions()

func _update_assumptions():
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

func has_assumptions():
	return get_child_count() != 0
