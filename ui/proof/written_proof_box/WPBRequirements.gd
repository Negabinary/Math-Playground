extends VBoxContainer
class_name WPBRequirements

signal requirement_selected # int

var requirements : Array

func show_requirements(requirements:Array, req_id:=0): #<ProofStep>
	self.requirements = requirements
	select_requirement(req_id)


func select_requirement(req_id:=0):
	for child in get_children():
		remove_child(child)
		child.disconnect("pressed", self, "emit_signal")
	for requirement in requirements:
		var new_label = WrittenJustification.new()
		# TODO: indicate whether proof is complete
		var icon := ""
		if requirement == requirements[req_id]:
			icon = ">"
		elif not requirement.is_proven():
			icon = "!"
		new_label.set_text(requirement.get_goal().to_string(), icon)
		add_child(new_label)
		new_label.connect(
			"pressed", 
			self, 
			"emit_signal", 
			["requirement_selected", requirements.find(requirement)]
		)
