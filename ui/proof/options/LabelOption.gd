extends Label

var option:Justification.LabelOption

func init(option:Justification.LabelOption):
	self.option = option
	text = option.get_text()
	if option.get_is_err():
		add_color_override("font_color", get_color("warning_color","WrittenJustification"))
	update()
