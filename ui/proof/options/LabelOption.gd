extends Label

var option:Justification.LabelOption
var text_listener:Autostring


func _update():
	text = text_listener.get_string()


func init(option:Justification.LabelOption):
	self.option = option
	text_listener = option.get_text()
	_update()
	if option.get_is_err():
		add_color_override("font_color", get_color("warning_color","WrittenJustification"))
	update()
