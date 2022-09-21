extends VBoxContainer
class_name WPBRequirements

signal requirement_selected # int

var proof_step : ProofStep
var requirements : Array
var req_id := 0

func show_requirements(proof_step:ProofStep, req_id:=-1): #<ProofStep>
	self.proof_step = proof_step
	requirements = proof_step.get_dependencies()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for i in len(requirements):
		var child = DependencyOption.new(requirements[i])
		child.connect("pressed", self, "emit_signal", ["requirement_selected", i])
		add_child(child)
	select_requirement(req_id)


func select_requirement(req_id:=0):
	self.req_id = req_id
	for i in len(requirements):
		if req_id == i:
			get_child(i).select()
		else:
			get_child(i).deselect()
