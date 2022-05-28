extends MarginContainer
class_name WPBJustification

signal justification_changed # -
signal change_active_dependency # int

var justification : Justification
var requirements : Array
var valid : bool

var ui_justification_name : Label
var ui_unprove_button : Button
var ui_description : Label
var ui_requirements : WPBRequirements
var ui_options : WPBOptions
var ui_panel : PanelContainer

var expr_item : ExprItem # final
var context : ProofBox # final
var selection_handler : SelectionHandler # final

var active_dependency := 0


# INITIALISATION ==========================================

func _find_ui_elements() -> void:
	ui_justification_name = $Options/VBoxContainer/HBoxContainer/JustificationName
	ui_unprove_button = $Options/VBoxContainer/HBoxContainer/UnproveButton
	ui_unprove_button.connect("pressed", self, "set_justification", [MissingJustification.new()])
	ui_description = $Options/VBoxContainer/JustificationDescription
	ui_requirements = $Options/VBoxContainer/VBoxContainer/Requirements
	self.ui_requirements.connect("requirement_selected", self, "_on_requirement_selected")
	ui_options = $Options/VBoxContainer/VBoxContainer/Options
	ui_options.connect("request_change_justification", self, "set_justification")
	ui_panel = $Options


func init(expr_item:ExprItem, context:ProofBox, selection_handler:SelectionHandler):
	self.expr_item = expr_item
	self.context = context
	context.connect("justified", self, "_on_expr_item_justified")
	self.selection_handler = selection_handler
	selection_handler.connect("locator_changed", self, "_on_locator_changed")
	_find_ui_elements()
	set_justification(context.get_justification_or_missing_for(expr_item))


# CHANGING JUSTIFIACTION ==================================

func set_justification(justification:Justification): #<Requirement>
	var kind_changed = (
		self.justification == null 
		or justification.get_script() != self.justification.get_script()
	)
	self.justification = justification
	if not justification.is_connected("updated", self, "_on_justification_updated"):
		justification.connect("updated", self, "_on_justification_updated")
	if not justification.is_connected("request_replace", self, "set_justification"):
		justification.connect("request_replace", self, "set_justification")
	ui_justification_name.text = justification.get_justification_text()
	ui_unprove_button.visible = not (justification is MissingJustification)
	if justification.get_justification_description():
		ui_description.show()
		ui_description.text = justification.get_justification_description()
	else:
		ui_description.hide()
	var jreq = justification.get_requirements_for(expr_item, context.get_parse_box())
	if jreq != null:
		requirements = jreq
		valid = true
	else:
		requirements = []
		valid = false
	ui_requirements.show_requirements(requirements)
	ui_options.set_options(justification.get_options_for_selection(expr_item, context.get_parse_box(), selection_handler.get_locator() if selection_handler.get_wpb() == get_parent().get_parent() else null))
	ui_panel.visible = not valid or (ui_panel.visible and not kind_changed)
	emit_signal("justification_changed") 

func _on_locator_changed(new_locator):
	ui_options.set_options(justification.get_options_for_selection(expr_item, context.get_parse_box(), selection_handler.get_locator() if selection_handler.get_wpb() == get_parent().get_parent() else null))

func _on_justification_updated(x=null):
	set_justification(justification)

func _on_requirement_selected(id):
	active_dependency = id
	ui_requirements.show_requirements(requirements, id)
	emit_signal("change_active_dependency")

func _on_expr_item_justified(uid:String):
	if uid == expr_item.get_unique_name():
		set_justification(context.get_justification_for(expr_item))

func get_requirements():
	return requirements

func get_is_valid():
	return valid

func get_justification_label():
	return justification.get_justification_text()

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
