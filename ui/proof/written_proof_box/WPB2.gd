extends MarginContainer
class_name WrittenProofBox2

var proof_step : ProofStep
var selection_handler # final

var ui_statement : WrittenStatement
var ui_missing_postit : Control
var ui_dependencies : MarginContainer
var ui_assumptions : Assumptions


var WPB_SCENE


# INITIALISATION ==========================================

func init(proof_step:ProofStep, selection_handler, WPB_SCENE):
	self.WPB_SCENE = WPB_SCENE
	self.proof_step = proof_step
	self.selection_handler = selection_handler
	_find_ui_elements()
	_connect_dependencies()
	_connect_active_dependency()
	$"%JustificationSummary".init(proof_step)
	$"%MissingPostit".init(proof_step, selection_handler)
	ui_statement.set_expr_item(proof_step.get_goal(), proof_step.get_inner_proof_box().get_parse_box())
	if proof_step.get_requirement().get_assumptions().size() > 0 or proof_step.get_requirement().get_definitions().size() > 0:
		ui_assumptions.display_assumptions(proof_step.get_requirement(), proof_step.get_inner_proof_box(), selection_handler)
	else:
		ui_assumptions.hide()
		add_constant_override("margin_left", 0)
	ui_statement.connect("selection_changed", self, "_on_ui_statement_selected")
	update()


func _find_ui_elements() -> void:
	ui_statement = $WrittenProofBox/Statement
	ui_dependencies = $WrittenProofBox/Dependencies
	ui_assumptions = $WrittenProofBox/MarginContainer/Assumptions


# GETTERS ==================================================


func get_goal() -> ExprItem:
	return proof_step.get_goal()


func get_inner_proof_box() -> SymmetryBox:
	return proof_step.get_inner_proof_box()


func get_selected_locator() -> Locator:
	return ui_statement.get_locator()


func get_proof_step() -> ProofStep:
	return proof_step


func get_wpb_child(index:int) -> WrittenProofBox2:
	if index < ui_dependencies.get_child_count():
		var wpb2 : WrittenProofBox2 = ui_dependencies.get_child(index)
		return wpb2
	else:
		return null


# DEPENDENCIES =================================================

func _connect_dependencies():
	proof_step.connect("dependencies_changed", self, "_change_dependencies")
	_change_dependencies()


signal now_has_dependencies

func _change_dependencies():
	var had_depdenencies = ui_dependencies.get_child_count() != 0
	var dependencies := proof_step.get_dependencies()
	for child in ui_dependencies.get_children():
		ui_dependencies.remove_child(child)
		child.queue_free()
	for new_dependency in dependencies:
		var new_ui_dependency = WPB_SCENE.instance()
		new_ui_dependency.init(new_dependency, selection_handler, WPB_SCENE)
		ui_dependencies.add_child(new_ui_dependency)
	_change_active_depenency()
	if not had_depdenencies and ui_dependencies.get_child_count() != 0:
		emit_signal("now_has_dependencies")


func _connect_active_dependency():
	proof_step.connect("active_dependency_changed", self, "_change_active_depenency")
	_change_active_depenency()


func _change_active_depenency():
	var dependency_id = proof_step.get_active_dependency()
	for child in ui_dependencies.get_children():
		if child.get_index() == dependency_id:
			child.show()
		else:
			child.hide()


enum ProofStatus {PROVEN, JUSTIFIED, UNPROVEN}


func is_proven() -> bool:
	return proof_step.is_proven()


# SELECTION ===============================================


func _on_ui_statement_selected(locator:Locator):
	selection_handler.locator_changed(locator, self)

func take_selection(locator:=null):
	if locator == null:
		ui_statement.set_locator(Locator.new(proof_step.get_goal()))
	else:
		ui_statement.set_locator(locator)
	

func select():
	pass

func deselect():
	ui_statement.deselect()


# DRAWING =================================================

func _draw():
	var ui_assumptions := $WrittenProofBox/MarginContainer/Assumptions
	if proof_step.get_requirement().get_assumptions().size() > 0 or proof_step.get_requirement().get_definitions().size() > 0:
		var font := get_font("font", "WrittenJustification")
		var half_font_height := font.get_height() / 2
		var color := get_color("font_color", "WrittenJustification")
		var x := 5 + get_constant("margin_left")
		draw_line(Vector2(x, half_font_height), Vector2(x, rect_size.y), color)
		for assumption in ui_assumptions.get_children():
			var y = assumption.rect_position.y + half_font_height
			draw_line(Vector2(x, y), Vector2(x + 17,y), color)
		draw_colored_polygon(PoolVector2Array([
			Vector2(x, rect_size.y),
			Vector2(x-4, rect_size.y-7),
			Vector2(x+4, rect_size.y-7)
		]), color)
