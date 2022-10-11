extends Label
class_name ExprItemAutostringLabel

export var multiline := false
var autostring : ExprItemAutostring setget set_autostring

func set_autostring(new_autostring:ExprItemAutostring):
	if autostring:
		autostring.disconnect("updated", self, "_on_update")
	autostring = new_autostring
	autostring.connect("updated", self, "_on_update")
	_on_update()

func _on_update():
	if multiline:
		text = autostring.get_multiline()
	else:
		text = autostring.get_string()
