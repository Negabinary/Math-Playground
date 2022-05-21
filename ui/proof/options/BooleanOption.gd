extends Control

var option = option

func init(option:Justification.BooleanOption):
	self.option = option
	$CheckButton.text = option.get_label()
	$CheckButton.disabled = option.get_disabled()
	$CheckButton.pressed = option.get_value()
	$CheckButton.connect("toggled", option, "set_value")
