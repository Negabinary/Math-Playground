extends Label

var option:Justification.LabelOption

func init(option:Justification.LabelOption):
	self.option = option
	text = option.get_text()
	add_color_override("font_color", Color.red if option.get_is_err() else Color.black)
	update()
