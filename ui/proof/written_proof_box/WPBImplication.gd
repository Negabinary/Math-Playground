extends WrittenProofBox


func _update_statement():
	._update_statement()
	$Assumptions.display_assumptions(proof_step)


func _draw():
	._draw()
	var ui_assumptions := $Assumptions
	
	var font := get_font("font", "WrittenJustification")
	var half_font_height := font.get_height() / 2
	var color := get_color("font_color", "WrittenJustification")
	draw_line(Vector2(15, half_font_height), Vector2(15, ui_justification_label.rect_position.y + half_font_height), color)
	for assumption in ui_assumptions.get_children():
		var y = assumption.rect_position.y + half_font_height
		draw_line(Vector2(15, y), Vector2(25,y), color)
	var y = ui_justification_label.rect_position.y + half_font_height
	draw_line(Vector2(15, y), Vector2(25,y), color)
