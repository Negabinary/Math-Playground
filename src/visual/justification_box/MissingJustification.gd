extends VBoxContainer


signal selected


var proof_step : ProofStep
var ui_implication_button : Button
var ui_vacuous_button : Button


func initialise(proof_step:ProofStep, main):
	main._on_proof_step_selected(proof_step)
	ui_implication_button = $MarginContainer/PanelContainer/VBoxContainer/ImplicationButton
	ui_vacuous_button = $MarginContainer/PanelContainer/VBoxContainer/VacuousButton
	self.proof_step = proof_step
	if proof_step.get_statement().as_expr_item().get_type() == GlobalTypes.IMPLIES:
		ui_implication_button.visible = true
		$MarginContainer/PanelContainer/VBoxContainer/Label2.visible = true
		ui_implication_button.connect("pressed", self, "_implication_button")
		ui_vacuous_button.connect("pressed", self, "_vacuous_button")
	else:
		ui_implication_button.visible = false
		ui_vacuous_button.visible = false
		$MarginContainer/PanelContainer/VBoxContainer/Label2.visible = false


func _implication_button():
	proof_step.justify_with_implication()


func _vacuous_button():
	proof_step.justify_with_vacuous()
