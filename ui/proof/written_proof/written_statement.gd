extends Control
class_name WrittenStatement

signal selection_changed

var expr_item : ExprItem
var context : AbstractParseBox

var is_selected = true
var selection = 0

var font : Font
var bold_font : Font
var offset : int
var font_color : Color

var locators := []
var rects := []

var string := ""

var rename_listeners := []


func get_locator() -> Locator:
	if len(locators) == 0:
		return Locator.new(expr_item)
	return locators[selection].get_locator()


func set_expr_item(new_expr_item:ExprItem, context:AbstractParseBox) -> void:
	expr_item = new_expr_item
	assert(context != null)
	self.context = context
	selection = 0
	is_selected = false
	update()


func deselect():
	is_selected = false
	update()


func select_whole():
	selection = 0
	is_selected = true
	update()


func _draw():
	font = get_font("font", "WrittenStatement")
	bold_font = get_font("bold_font", "WrittenStatement")
	offset = get_constant("indentation", "WrittenProof")
	font_color = get_color("font_color", "WrittenStatement")
	
	locators = []
	rects = []
	var xe = _draw_locator(ContextLocator.new(Locator.new(expr_item), context), offset)
	
	if is_selected:
		var rect = rects[selection]
		draw_style_box(get_stylebox("highlighted", "WrittenStatement"), rect)
	
	xe = _draw_locator(ContextLocator.new(Locator.new(expr_item), context), offset)
	
	set_custom_minimum_size(Vector2(xe, font.get_height()))


func _draw_locator(locator:ContextLocator, x0:float) -> float:
	for rl in rename_listeners:
		locator.get_context().remove_listener(rl)
	rename_listeners.clear()
	var xe : float
	if locator.get_type() == GlobalTypes.IMPLIES and locator.get_child_count() == 2:
		if locator.get_parent_type() in [GlobalTypes.AND, GlobalTypes.OR, GlobalTypes.EQUALITY]:
			var x1 = _draw_string("(", x0)
			var x2 = _draw_string("if ", x1, true)
			var x3 = _draw_locator(locator.get_child(0), x2)
			var x4 = _draw_string(" then ", x3, true)
			var x5 = _draw_locator(locator.get_child(1), x4)
			xe = _draw_string(")", x5)
		else:
			var x2 = _draw_string("if ", x0, true)
			var x3 = _draw_locator(locator.get_child(0), x2)
			var x4 = _draw_string(" then ", x3, true)
			xe = _draw_locator(locator.get_child(1), x4)
	elif locator.get_type() == GlobalTypes.FORALL and locator.get_child_count() == 2:
		if locator.get_parent_type() in [GlobalTypes.AND, GlobalTypes.OR, GlobalTypes.EQUALITY]:
			var x1 = _draw_string("(", x0)
			var x2 = _draw_string("forall ", x1, true)
			var x3 = _draw_locator(locator.get_child(0), x2)
			var x4 = _draw_string(". ", x3)
			var x5 = _draw_locator(locator.get_child(1), x4)
			xe = _draw_string(")", x5)
		else:
			var x2 = _draw_string("forall ", x0, true)
			var x3 = _draw_locator(locator.get_child(0), x2)
			var x4 = _draw_string(". ", x3)
			xe = _draw_locator(locator.get_child(1), x4)
	elif locator.get_type() == GlobalTypes.EXISTS and locator.get_child_count() == 2:
		if locator.get_parent_type() in [GlobalTypes.AND, GlobalTypes.OR, GlobalTypes.EQUALITY]:
			var x1 = _draw_string("(", x0)
			var x2 = _draw_string("exists ", x1, true)
			var x3 = _draw_locator(locator.get_child(0), x2)
			var x4 = _draw_string(". ", x3, true)
			var x5 = _draw_locator(locator.get_child(1), x4)
			xe = _draw_string(")", x5)
		else:
			var x2 = _draw_string("exists ", x0, true)
			var x3 = _draw_locator(locator.get_child(0), x2)
			var x4 = _draw_string(". ", x3)
			xe = _draw_locator(locator.get_child(1), x4)
	elif locator.get_type() == GlobalTypes.LAMBDA and locator.get_child_count() == 2:
		if locator.get_parent_type() in [GlobalTypes.AND, GlobalTypes.OR, GlobalTypes.EQUALITY]:
			var x1 = _draw_string("(", x0)
			var x2 = _draw_string("fun ", x1, true)
			var x3 = _draw_locator(locator.get_child(0), x2)
			var x4 = _draw_string(". ", x3)
			var x5 = _draw_locator(locator.get_child(1), x4)
			xe = _draw_string(")", x5)
		else:
			var x2 = _draw_string("fun ", x0, true)
			var x3 = _draw_locator(locator.get_child(0), x2)
			var x4 = _draw_string(". ", x3, true)
			xe = _draw_locator(locator.get_child(1), x4)
	elif locator.get_type() == GlobalTypes.LAMBDA and locator.get_child_count() > 2:
		var x1 = _draw_string("(", x0)
		var x2 = _draw_string("fun ", x1, true)
		var x3 = _draw_locator(locator.get_child(0), x2)
		var x4 = _draw_string(". ", x3)
		var x5 = _draw_locator(locator.get_child(1), x4)
		xe = _draw_string(")", x5)
		xe = _draw_string("(", xe)
		for i in range(2, locator.get_child_count()):
			xe = _draw_locator(locator.get_child(i), xe)
			if i < locator.get_child_count() - 1:
				xe = _draw_string(", ", xe)
		xe = _draw_string(")", xe)
	elif locator.get_type() == GlobalTypes.AND and locator.get_child_count() == 2:
		if locator.get_parent_type() in [GlobalTypes.EQUALITY, GlobalTypes.AND]:
			var x1 = _draw_string("(", x0)
			var x3 = _draw_locator(locator.get_child(0), x1)
			var x4 = _draw_string(" and ", x3, true)
			var x5 = _draw_locator(locator.get_child(1), x4)
			xe = _draw_string(")", x5)
		else:
			var x3 = _draw_locator(locator.get_child(0), x0)
			var x4 = _draw_string(" and ", x3, true)
			xe = _draw_locator(locator.get_child(1), x4)
	elif locator.get_type() == GlobalTypes.OR and locator.get_child_count() == 2:
		if locator.get_parent_type() in [GlobalTypes.EQUALITY, GlobalTypes.AND, GlobalTypes.OR]:
			var x1 = _draw_string("(", x0)
			var x3 = _draw_locator(locator.get_child(0), x1)
			var x4 = _draw_string(" or ", x3, true)
			var x5 = _draw_locator(locator.get_child(1), x4)
			xe = _draw_string(")", x5)
		else:
			var x3 = _draw_locator(locator.get_child(0), x0)
			var x4 = _draw_string(" or ", x3, true)
			xe = _draw_locator(locator.get_child(1), x4)
	elif locator.get_type() == GlobalTypes.EQUALITY and locator.get_child_count() == 2:
		if locator.get_parent_type() in [GlobalTypes.EQUALITY]:
			var x1 = _draw_string("(", x0)
			var x3 = _draw_locator(locator.get_child(0), x1)
			var x4 = _draw_string(" = ", x3)
			var x5 = _draw_locator(locator.get_child(1), x4)
			xe = _draw_string(")", x5)
		else:
			var x3 = _draw_locator(locator.get_child(0), x0)
			var x4 = _draw_string(" = ", x3)
			xe = _draw_locator(locator.get_child(1), x4)
	else:
		var listener := locator.get_type_listener()
		xe = _draw_string(listener.get_full_string() + "#" + str(locator.get_type().get_uid()), x0)
		listener.connect("renamed", self, "update")
		rename_listeners.append(listener)
		if locator.get_child_count() > 0:
			xe = _draw_string("(", xe)
			for i in range(0, locator.get_child_count()):
				xe = _draw_locator(locator.get_child(i), xe)
				if i < locator.get_child_count() - 1:
					xe = _draw_string(", ", xe)
			xe = _draw_string(")", xe)
	
	locators.append(locator)
	rects.append(Rect2(
		x0, 0, xe - x0, font.get_height()
	))
	return xe


func _draw_string(string:String, x:float, bold:=false) -> float:
	draw_string(bold_font if bold else font, Vector2(x, font.get_ascent()), string, font_color)
	return x + (bold_font if bold else font).get_string_size(string).x


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and is_visible_in_tree():
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
