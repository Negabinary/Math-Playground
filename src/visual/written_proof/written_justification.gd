extends TextureButton
class_name WrittenJustification

export var j_text : String = "USING BLACK MAGIC (i.e. This is sound but I haven't implemented a visualisation for this reasoning yet)"
export var icon : String

func set_text(new_text:String, new_icon:="") -> void:
	j_text = new_text
	icon = new_icon
	update()

func _draw():
	var font := get_font("font", "WrittenJustification")
	var offset := get_constant("indentation", "WrittenProof")
	var font_color = get_color("font_color_hover" if get_draw_mode() == DRAW_HOVER or get_draw_mode() == DRAW_HOVER_PRESSED else "font_color", "WrittenJustification")
	var icon_color:Color = font_color if icon != "!" else get_color("warning_color", "WrittenJustification")
	var icon_font:Font = get_font("warning_font", "WrittenJustification")
	draw_string(icon_font, Vector2((offset-icon_font.get_string_size(icon).x)/2, icon_font.get_ascent()), icon, icon_color)
	draw_string(font, Vector2(offset, font.get_ascent()), j_text, font_color)
	set_custom_minimum_size(Vector2(offset, 0) + font.get_string_size(j_text))
