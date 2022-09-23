extends Control

var proof_step : ProofStep
var selection_handler : SelectionHandler

func init(proof_step:ProofStep, selection_handler):
	self.proof_step = proof_step
	self.selection_handler = selection_handler
	proof_step.connect("dependencies_changed", self, "_update")
	selection_handler.connect("locator_changed", self, "_update")
	_update()


func _update():
	var justification := proof_step.get_justification()
	visible = justification is MissingJustification
	if visible:
		var selection = null
		if selection_handler.get_wpb() == get_parent().get_parent():
			selection = selection_handler.get_locator()
		$"%Options".set_options(
			justification.get_options_for_selection(
				proof_step.get_goal(), 
				proof_step.get_inner_proof_box().get_parse_box(), 
				selection
			)
		)
