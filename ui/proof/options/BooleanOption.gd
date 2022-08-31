extends Control

var option:Justification.BooleanOption
var text_listener:Autostring

func _update():
	$CheckButton.text = text_listener.get_string()

func init(option:Justification.BooleanOption):
	self.option = option
	self.text_listener = option.get_label()
	$CheckButton.text = text_listener.get_string()
	text_listener.connect("updated", self, "_update")
	$CheckButton.disabled = option.get_disabled()
	$CheckButton.pressed = option.get_value()
	$CheckButton.connect("toggled", option, "set_value")
