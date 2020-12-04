extends Control
class_name WrittenStatement

signal selection_changed

var expr_item : ExprItem = ExprItem.from_string("MISSING")

var is_selected = true
var selection = 0

var font : Font
var offset : int
var font_color : Color

var locators := []
var rects := []

var string := ""


func set_expr_item(new_expr_item:ExprItem) -> void:
	expr_item = new_expr_item
	selection = 0
	is_selected = false
	update()


func deselect():
	is_selected = false


func _draw():
	font = get_font("font", "WrittenStatement")
	offset = get_constant("indentation", "WrittenProof")
	font_color = get_color("font_color", "WrittenStatement")
	
	string = ""
	locators = Locator.new(expr_item).get_postorder_locator_list()
	rects = expr_item.get_postorder_rect_list(font, offset)
	
	if is_selected:
		var rect = rects[selection]
		draw_style_box(get_stylebox("highlighted", "WrittenStatement"), rect)
	
	draw_string(font, Vector2(offset, font.get_ascent()), expr_item.to_string(), font_color)
	set_custom_minimum_size(Vector2(offset, 0) + font.get_string_size(expr_item.to_string()))


func get_drag_data(position): # -> UniversalLocator
	if is_selected:
		var locator : Locator = locators[selection]
		return UniversalLocator.new(Statement.new(locator.get_root()), locator)
	else:
		return null


func _input(event):
	if event is InputEventMouseButton:
		var position = event.position - get_global_rect().position
		for i in rects.size():
			if rects[i].has_point(position):
				if Input.is_key_pressed(KEY_SHIFT):
					var parent:Locator = locators[i].get_parent()
					selection = i
					is_selected = true
					update()
					emit_signal("selection_changed", locators[i])
					break
				else:
					selection = i
					is_selected = true
					update()
					emit_signal("selection_changed", locators[i])
					break
