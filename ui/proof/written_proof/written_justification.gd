extends TextureButton
class_name WrittenJustification

var j_text = ConstantAutostring.new("USING BLACK MAGIC (i.e. This is sound but I haven't implemented a visualisation for this reasoning yet)")
var text := ""
export var icon : String


func set_text(new_text, new_icon:="") -> void:
	if j_text.is_connected("updated", self, "update"):
		j_text.disconnect("updated", self, "update")
	if new_text is String:
		j_text = ConstantAutostring.new(new_text)
	else:
		j_text = new_text
	j_text.connect("updated", self, "_update_text")
	text = j_text.get_string()
	icon = new_icon
	update()


func _update_text():
	text = j_text.get_string()
	update()


func _draw():
	var font := get_font("font", "WrittenJustification")
	var offset := get_constant("indentation", "WrittenProof")
	var font_color = get_color("font_color_hover" if get_draw_mode() == DRAW_HOVER or get_draw_mode() == DRAW_HOVER_PRESSED else "font_color", "WrittenJustification")
	var icon_color:Color = font_color if not icon in ["!","x"] else get_color("warning_color", "WrittenJustification")
	var icon_font:Font = get_font("warning_font", "WrittenJustification")
	draw_string(icon_font, Vector2((offset-icon_font.get_string_size(icon).x)*2/3, icon_font.get_ascent()), icon, icon_color)
	var opener = "" #if toggle_mode == false else ("- " if pressed else "+ ")
	draw_string(font, Vector2(offset, font.get_ascent()), opener + text, font_color)
	set_custom_minimum_size(Vector2(offset, 0) + font.get_string_size(opener + text))
