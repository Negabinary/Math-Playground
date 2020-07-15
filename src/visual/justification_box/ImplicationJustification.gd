extends VBoxContainer

var proof_step : ProofStep

func initialise(proof_step:ProofStep, main):
	var ui_assumptions := $Assumptions
	var ui_justification := $Justification
	var ui_next := $Indent/Next
	var ui_justification_label := $JustificationLabel
	
	$Justification.remove_child($Justification.get_child(0))
	if self.proof_step != null:
		self.proof_step.get_requirements()[0].disconnect("justified", self, "initialise")
	
	self.proof_step = proof_step
	
	var requirements := proof_step.get_requirements()
	
	ui_assumptions.display_assumptions(proof_step)
	
	var j_box = load("res://src/visual/justification_box/justification_box_builder.gd").build(requirements[0], main)
	ui_justification.add_child(j_box)
	
	ui_next.set_expr_item(requirements[0].get_statement().as_expr_item())
	
	ui_justification_label.set_text("THUS")
	
	requirements[0].connect("justified", self, "initialise", [proof_step, main])

func _draw():
	var ui_assumptions := $Assumptions
	var ui_justification_label := $JustificationLabel
	
	var font := get_font("font", "WrittenJustification")
	var half_font_height := font.get_height() / 2
	var color := get_color("font_color", "WrittenJustification")
	draw_line(Vector2(15, half_font_height), Vector2(15, rect_size.y - half_font_height), color)
	for assumption in ui_assumptions.get_children():
		var y = assumption.rect_position.y + half_font_height
		draw_line(Vector2(15, y), Vector2(25,y), color)
	var y = ui_justification_label.rect_position.y + half_font_height
	draw_line(Vector2(15, y), Vector2(25,y), color)
