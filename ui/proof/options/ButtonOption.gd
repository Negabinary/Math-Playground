extends Control

var option:Justification.ButtonOption
var text_listener:Autostring

func _update():
	$Button.text = text_listener.get_string()

func init(option:Justification.ButtonOption):
	self.option = option
	self.text_listener = option.get_text()
	$Button.text = text_listener.get_string()
	text_listener.connect("updated", self, "_update")
	$Button.disabled = option.get_is_disabled()
	$Button.icon = option.get_image()
	if $Button.icon:
		rect_min_size = $Button.icon.get_size() + Vector2(10,10)
		$Button.text = ""
	$Button.connect("pressed", self, "_on_pressed")

func _on_pressed():
	print("HERE")
	option.action()
