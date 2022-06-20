extends PanelContainer

signal dependency_selected

var justification:Justification


func _toggle_visibility():
	if visible:
		hide()
	else:
		show()


func display_justification(justification:Justification, req_id:int):
	self.justification = justification
	_display_requirements(req_id)
	$VBoxContainer/HBoxContainer/JustificationName.text = "Justification Options"
	_display_options()


func _on_requirements_pressed(req_id:int):
	emit_signal("dependency_selected", req_id)
	_display_requirements(req_id)


func _display_requirements(req_id:int):
	var ui_requirements := $VBoxContainer/VBoxContainer/Requirements
	for child in ui_requirements.get_children():
		ui_requirements.remove_child(child)
	var requirements = justification.get_requirements()
	for requirement in requirements:
		var new_label = WrittenJustification.new()
		new_label.set_text(requirement.get_statement().to_string(), ">" if requirement == requirements[req_id] else ("" if requirement.is_proven() else "!"))
		ui_requirements.add_child(new_label)
		new_label.connect("pressed", self, "emit_signal", ["dependency_selected", requirements.find(requirement)])
		new_label.connect("pressed", self, "_on_requirement_pressed", [requirements.find(requirement)])


func _display_options():
	var ui_options := $VBoxContainer/VBoxContainer/VBoxContainer/Options
	var options = justification.get_options()
	for i in options.size():
		var new_label = WrittenJustification.new()
		new_label.disabled = justification.get_option_disabled(i)
		new_label.set_text(options[i], "/" if justification.get_option(i) else "X")
		new_label.connect("pressed", self, "_option_pressed", [i])
		ui_options.add_child(new_label)


func _option_pressed(idx:int):
	justification.set_option(idx, !justification.get_option(idx))
