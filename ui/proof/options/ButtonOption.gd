extends Control

var option:Justification.ButtonOption

func init(option:Justification.ButtonOption):
	self.option = option
	$Button.text = option.get_text()
	$Button.disabled = option.get_is_disabled()
	$Button.icon = option.get_image()
	if $Button.icon:
		rect_min_size = $Button.icon.get_size() + Vector2(10,10)
		$Button.text = ""
	$Button.connect("pressed", self, "_on_pressed")

func _on_pressed():
	print("HERE")
	option.action()
