extends Control

var option:Justification.LabelOption

func init(option:Justification.LabelOption):
	self.option = option
	$Label.text = option.get_text()
	$Label.modulate = Color.red if option.get_is_err() else Color.black
