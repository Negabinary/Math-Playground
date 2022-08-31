extends Label
class_name AutostringLabel

var autostring : Autostring setget set_autostring

func set_autostring(new_autostring:Autostring):
	if autostring:
		autostring.disconnect("updated", self, "_on_update")
	autostring = new_autostring
	autostring.connect("updated", self, "_on_update")
	_on_update()

func _on_update():
	text = autostring.get_string()
