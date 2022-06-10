extends Control

var option:Justification.ButtonOption

func init(option:Justification.ButtonOption):
	self.option = option
	$Button.text = option.get_text()
	$Button.disabled = option.get_is_disabled()
	$Button.connect("pressed", self, "_on_pressed")

func _on_pressed():
	option.action()
