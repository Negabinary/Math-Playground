extends Control
class_name WPBJustification

signal change_active_dependency # int

var ui_justification_name : Label
var ui_unprove_button : Button
var ui_description : Label
var ui_requirements : WPBRequirements
var ui_req_separator : Control
var ui_options : WPBOptions
var ui_panel : Control

var proof_step : ProofStep
var selection_handler : SelectionHandler # final

var active_dependency := 0


# INITIALISATION ==========================================

func _find_ui_elements() -> void:
	ui_justification_name = $"%JustificationName"
	ui_unprove_button = $"%UnproveButton"
	ui_description = $"%JustificationDescription"
	ui_requirements = $"%Requirements"
	self.ui_requirements.connect("requirement_selected", self, "_on_requirement_selected")
	ui_req_separator = $"%ReqSeparator"
	ui_options = $"%Options"
	ui_panel = $"%OptionsPanel"


func init(proof_step:ProofStep, selection_handler:SelectionHandler):
	_find_ui_elements()
	self.proof_step = proof_step
	ui_unprove_button.connect("pressed", proof_step, "justify", [MissingJustification.new()])
	proof_step.connect("justification_type_changed", self, "_on_justification_changed")
	proof_step.connect("justification_properties_changed", self, "_on_justification_updated")
	self.selection_handler = selection_handler
	_on_justification_changed()


# CHANGING JUSTIFIACTION ==================================

func _on_justification_changed():
	_on_justification_updated()
	ui_panel.visible = not proof_step.is_justification_valid()


func _on_justification_updated():
	var justification = proof_step.get_justification()
	ui_justification_name.autostring = justification.get_justification_text(proof_step.get_inner_proof_box().get_parse_box())
	ui_unprove_button.visible = not (justification is MissingJustification or justification is AssumptionJustification or justification is CircularJustification)
	ui_requirements.visible = not (justification is MissingJustification or justification is AssumptionJustification or justification is CircularJustification)
	ui_options.columns = 1 if justification is MissingJustification else 1
	ui_req_separator.visible = not (justification is MissingJustification)
	if justification.get_justification_description():
		ui_description.show()
		ui_description.text = justification.get_justification_description()
	else:
		ui_description.hide()
	var reqs := proof_step.get_dependencies()
	ui_requirements.show_requirements(proof_step)
	if reqs.size() > 0:
		_on_requirement_selected(0)
	var selection = null
	if selection_handler.get_wpb() == get_parent().get_parent():
		selection = selection_handler.get_locator()
	# todo: move this code into MissingJustification
	ui_options.set_options(
		justification.get_options_for_selection(
			proof_step.get_goal(), 
			proof_step.get_inner_proof_box().get_parse_box(), 
			selection
		)
	)


func locator_changed(new_locator):
	# todo: move this code into MissingJustification
	ui_options.set_options(
		proof_step.get_justification().get_options_for_selection(
			proof_step.get_goal(), 
			proof_step.get_inner_proof_box().get_parse_box(), 
			selection_handler.get_locator() 
			if selection_handler.get_wpb() == get_parent().get_parent() 
			else null
		)
	)


func _on_requirement_selected(id):
	active_dependency = id
	ui_requirements.select_requirement(id)
	emit_signal("change_active_dependency")


func get_active_dependency():
	return active_dependency


# UI ======================================================

func hide_panel():
	ui_panel.hide()

func show_panel():
	ui_panel.show()

func toggle_panel():
	ui_panel.visible = not ui_panel.visible

func _toggle_visibility():
	toggle_panel()
