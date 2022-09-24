extends TextEdit

func _ready():
	connect("text_changed", self, "_on_text_changed")
	rect_min_size.y = get_line_count() * get_line_height()


func _on_text_changed():
	rect_min_size.y = get_line_count() * get_line_height()
