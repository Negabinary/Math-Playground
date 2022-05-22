extends Control

var type:ExprItemType

func init(option:Justification.ExprItemTypeNameOption):
	self.type = option.get_type()
	$LineEdit.text = type.to_string()
	$LineEdit.connect("text_changed", self, "_text_changed")


func _text_changed():
	if $LineEdit.text != "": # TODO : there should be more checks to see if a name is valid
		type.rename($LineEdit.text)
	else:
		type.rename("???")
