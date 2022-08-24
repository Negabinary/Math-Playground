extends VBoxContainer
class_name WPBRequirements

signal requirement_selected # int

var proof_step : ProofStep
var requirements : Array

func show_requirements(proof_step:ProofStep, req_id:=0): #<ProofStep>
	self.proof_step = proof_step
	self.requirements = proof_step.get_dependencies()
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
		new_label.set_text(
			requirement.get_inner_proof_box().get_parse_box().printout(requirement.get_goal()), 
			icon
		)
		add_child(new_label)
		new_label.connect(
			"pressed", 
			self, 
			"emit_signal", 
			["requirement_selected", requirements.find(requirement)]
		)
