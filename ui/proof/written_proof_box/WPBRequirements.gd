extends VBoxContainer
class_name WPBRequirements

signal requirement_selected # int

var proof_step : ProofStep
var requirements : Array
var req_id : int
var req_autostrings := []

func show_requirements(proof_step:ProofStep, req_id:=0): #<ProofStep>
	self.proof_step = proof_step
	for ra in req_autostrings:
		ra.disconnect("updated", self, "_update_string")
	req_autostrings.clear()
	self.requirements = proof_step.get_dependencies()
	for rq in self.requirements:
		var autostring := ExprItemAutostring.new(
			rq.get_goal(), rq.get_inner_proof_box().get_parse_box()
		)
		req_autostrings.append(autostring)
	select_requirement(req_id)


func select_requirement(req_id:=0):
	self.req_id = req_id
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for i in len(requirements):
		var new_label = WrittenJustification.new()
		# TODO: indicate whether proof is complete
		var icon := ""
		if i == req_id:
			icon = ">"
		elif not requirements[i].is_proven():
			icon = "!"
		new_label.set_text(
			req_autostrings[i], 
			icon
		)
		add_child(new_label)
		new_label.connect(
			"pressed", 
			self, 
			"emit_signal", 
			["requirement_selected", i]
		)
