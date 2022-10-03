extends TextEdit

func _ready():
	connect("text_changed", self, "_on_text_changed")
	_on_text_changed()


func set_text(t):
	text = t
	_on_text_changed()


func _on_text_changed():
	rect_min_size.y = (get_line_count() + 1) * get_line_height()
