extends VBoxContainer

var module : MathModule


func set_module(module:MathModule):
	if self.module != null:
		self.module.disconnect("requirements_updated", self, "_on_requirements_updated")
	self.module = module
	if self.module != null:
		self.module.connect("requirements_updated", self, "_on_requirements_updated")


func _on_requirements_updated():
	for child in get_children():
		remove_child(child)
	for requirement in module.get_requirements():
		var label = Label.new()
		label.text = requirement.get_name() + " - " + str(requirement.get_definitions())
		add_child(label)
