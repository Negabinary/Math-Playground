extends Control
class_name WrittenStatement

var expr_item : ExprItem = ExprItem.from_string("MISSING")

func set_expr_item(new_expr_item:ExprItem) -> void:
	expr_item = new_expr_item
	update()

func _draw():
	var font := get_font("font", "WrittenStatement")
	var offset := get_constant("indentation", "WrittenProof")
	var font_color = get_color("font_color", "WrittenStatement")
	draw_string(font, Vector2(offset, font.get_ascent()), expr_item.to_string(), font_color)
	set_custom_minimum_size(Vector2(offset, 0) + font.get_string_size(expr_item.to_string()))
	print(rect_size)
	print(rect_min_size)
	print(offset)
