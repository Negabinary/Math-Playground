extends Control
class_name WrittenStatement

var expr_item : ExprItem = ExprItem.from_string("MISSING")

var font : Font
var offset : int
var font_color : Color

var locator_to_regions := {}


func set_expr_item(new_expr_item:ExprItem) -> void:
	expr_item = new_expr_item
	update()


func _draw():
	font = get_font("font", "WrittenStatement")
	offset = get_constant("indentation", "WrittenProof")
	font_color = get_color("font_color", "WrittenStatement")
	draw_string(font, Vector2(offset, font.get_ascent()), expr_item.to_string(), font_color)
	set_custom_minimum_size(Vector2(offset, 0) + font.get_string_size(expr_item.to_string()))
	print(rect_size)
	print(rect_min_size)
	print(offset)
