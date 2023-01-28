extends TextEdit
class_name ExprItemEntry

export var auto_expand := true

func _ready():
	connect("text_changed", self, "_on_text_changed")
	_on_text_changed()
	syntax_highlighting = true
	clear_colors()
	var keywords = [
		'import', 'define', 'assume', 'show', 'forall', 'exists', 'fun', 'if', 'then', 
		'_import_', '_define_', "_import_", "_define_", "_assume_", "_show_", "_forall_", 
		"_exists_", "_fun_", "_if_", "_then_", "_->_", "as","and", "or", ":", ".", "=", ","
	]
	for keyword in keywords:
		add_keyword_color(keyword, Color("#2A9D8F"))


func set_text(t):
	text = t
	_on_text_changed()


func _on_text_changed():
	if auto_expand:
		rect_min_size.y = (get_line_count() + 1) * get_line_height()
