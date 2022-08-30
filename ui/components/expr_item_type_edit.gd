extends LineEdit
class_name ExprItemTypeEdit

var type := ExprItemType.new("???") setget set_type

func _init():
	type.connect("renamed", self, "_on_renamed")
	connect("text_changed", self, "_on_text_change")
	text = type.get_identifier()

func set_type(new_type:ExprItemType):
	type.disconnect("renamed", self, "_on_renamed")
	type = new_type
	type.connect("renamed", self, "_on_renamed")
	text = type.get_identifier()

func _on_renamed():
	if not has_focus():
		text = type.get_identifier()

func _on_text_change(new_text):
	type.rename(new_text)
