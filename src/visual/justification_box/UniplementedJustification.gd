extends VBoxContainer

var proof_step : ProofStep
var req_id : int

func initialise(proof_step:ProofStep, main, req_id:=-1):
	var ui_justification = $Justification
	var ui_next = $Next
	var ui_justification_label = $JustificationLabel
	var ui_panel = $MarginContainer/Panel

	ui_justification.remove_child(ui_justification.get_child(0))
	if self.proof_step != null:
		self.proof_step.get_requirements()[self.req_id].disconnect("justified", self, "initialise")

	self.proof_step = proof_step
	var requirements := proof_step.get_requirements()

	if req_id == -1:
		if requirements.size() == 1:
			req_id = 0
			ui_justification_label.disabled = true
		elif self.proof_step == proof_step:
			req_id = self.req_id
		else:
			req_id = 1
			ui_justification_label.disabled = false
	self.req_id = req_id

	var conditions_met := true
	for requirement in requirements:
		if requirement != requirements[req_id]:
			if not requirement.is_proven():
				conditions_met = false

	var j_box = load("res://src/visual/justification_box/justification_box_builder.gd").build(requirements[req_id], main)
	ui_justification.add_child(j_box)

	ui_next.set_expr_item(requirements[req_id].get_statement().as_expr_item())

	var icon = "" if conditions_met else "!"
	ui_justification_label.set_text(proof_step.get_justification_text(), icon)

	ui_panel.display_requirements(proof_step, self, req_id, main)

	requirements[req_id].connect("justified", self, "initialise", [proof_step, main])
