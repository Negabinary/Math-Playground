extends MarginContainer
class_name WPBJustification

signal justification_changed

var justification : Justification
var expr_item : ExprItem
var context : ProofBox
var requirements : Array

var ui_justification_name : Label
var ui_unprove_button : Button
var ui_description : Label
var ui_requirements : WPBRequirements
var ui_options : WPBOptions
var ui_panel : PanelContainer

func _ready():
	ui_justification_name = $Options/VBoxContainer/HBoxContainer/JustificationName
	ui_unprove_button = $Options/VBoxContainer/HBoxContainer/UnproveButton
	ui_description = $Options/VBoxContainer/JustificationDescription
	ui_requirements = $Options/VBoxContainer/VBoxContainer/Requirements
	ui_options = $Options/VBoxContainer/VBoxContainer/Options
	ui_panel = $Options

func init(expr_item:ExprItem, context:ProofBox):
	self.expr_item = expr_item
	set_justification(context.get_justification_or_missing_for(expr_item))
	context.connect("justified", self, "_on_expr_item_justified")

func set_justification(justification:Justification): #<Requirement>
	if self.justification:
		self.justification.disconnect("justification_changed", self, "_on_justification_updated")
	self.justification = justification
	ui_justification_name.text = justification.get_justification_text()
	ui_unprove_button.visible = not (justification is MissingJustification)
	var description = justification.get_justification_description()
	if description:
		ui_description.show()
		ui_description.text = justification.get_justification_description()
	else:
		ui_description.hide()
	requirements = justification.get_requirements_for(expr_item, context)
	ui_requirements.show_requirements(requirements)
	ui_options.show_options(justification.get_options_for(expr_item, context))
	ui_options.connect("request_change_justification", self, "set_justification")
	ui_panel.visible = requirements == null
	justification.connect("justification_changed", self, "_on_justification_updated")
	emit_signal("justification_changed") 

func _on_justification_updated():
	set_justification(justification)

func _on_expr_item_justified(uid:String):
	if uid == expr_item.get_unique_name():
		set_justification(context.get_justification_for(expr_item))

func get_requirements():
	return requirements

func hide_panel():
	ui_panel.hide()

func show_panel():
	ui_panel.show()

func toggle_panel():
	ui_panel.visible = not ui_panel.visible
