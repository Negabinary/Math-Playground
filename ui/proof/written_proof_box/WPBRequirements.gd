extends VBoxContainer
class_name WPBRequirements

signal requirement_selected # int

func show_requirements(requirements:Array, req_id=0): #<Requirements>
	for child in get_children():
		remove_child(child)
		child.disconnect("pressed", self, "emit_signal")
	for requirement in requirements:
		var new_label = WrittenJustification.new()
		new_label.set_text(requirement.get_statement().to_string(), ">" if requirement == requirements[req_id] else ("" if requirement.is_proven() else "!"))
		add_child(new_label)
		new_label.connect("pressed", self, "emit_signal", ["requirement_selected", requirements.find(requirement)])
