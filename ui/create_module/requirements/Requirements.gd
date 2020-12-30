extends VBoxContainer

var module : MathModule


func set_module(module:MathModule):
	if self.module != null:
		self.module.disconnect("requirements_updated", self, "_on_requirements_updated")
	for child in get_children():
		remove_child(child)
	self.module = module
	for req in module.get_requirements():
		_add_requirement(req)
	if self.module != null:
		self.module.connect("requirements_updated", self, "_on_requirements_updated")


func _on_requirements_updated():
	for child in get_children():
		remove_child(child)
	for requirement in module.get_requirements():
		_add_requirement(requirement)


func _add_requirement(requirement:MathModule):
	var label = Label.new()
	label.text = requirement.get_name() + " - " + str(requirement.get_definitions())
	add_child(label)
