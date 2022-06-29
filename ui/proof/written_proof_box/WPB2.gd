extends MarginContainer
class_name WrittenProofBox2

var proof_step : ProofStep
var selection_handler # final

var ui_statement : WrittenStatement
var ui_justification_holder : WPBJustification
var ui_justification_label : WrittenJustification
var ui_dependencies : MarginContainer
var ui_assumptions : Assumptions


var WPB_SCENE = load("res://ui/proof/written_proof_box/WPB2.tscn")


# INITIALISATION ==========================================

func init(proof_step:ProofStep, selection_handler):
	self.proof_step = proof_step
	self.selection_handler = selection_handler
	_find_ui_elements()
	ui_justification_holder.init(proof_step, selection_handler)
	_connect_dependencies()
	_connect_active_dependency()
	_connect_justification_label()
	ui_statement.set_expr_item(proof_step.get_goal())
	if proof_step.get_requirement().get_assumptions().size() > 0 or proof_step.get_requirement().get_definitions().size() > 0:
		ui_assumptions.display_assumptions(proof_step.get_requirement(), proof_step.get_inner_proof_box(), selection_handler)
	else:
		ui_assumptions.hide()
		add_constant_override("margin_left", 0)
	ui_statement.connect("selection_changed", self, "_on_ui_statement_selected")
	update()


func _find_ui_elements() -> void:
	ui_statement = $WrittenProofBox/Statement
	ui_justification_holder = $WrittenProofBox/Justification
	ui_justification_label = $WrittenProofBox/JustificationLabel
	ui_dependencies = $WrittenProofBox/Dependencies
	ui_assumptions = $WrittenProofBox/MarginContainer/Assumptions


# GETTERS ==================================================


func get_goal() -> ExprItem:
	return proof_step.get_goal()


func get_inner_proof_box() -> ProofBox:
	return proof_step.get_inner_proof_box()


func get_selected_locator() -> Locator:
	return ui_statement.get_locator()


# DEPENDENCIES =================================================

func _connect_dependencies():
	proof_step.connect("dependencies_changed", self, "_change_dependencies")
	_change_dependencies()


func _change_dependencies():
	var keepers := {}
	var dependencies := proof_step.get_dependencies()
	var old_children = ui_dependencies.get_children()
	for child in ui_dependencies.get_children():
		ui_dependencies.remove_child(child)
	for new_dependency in dependencies:
		var new_ui_dependency = WPB_SCENE.instance()
		new_ui_dependency.init(new_dependency, selection_handler)
		ui_dependencies.add_child(new_ui_dependency)
	_change_active_depenency()


func _connect_active_dependency():
	ui_justification_holder.connect("change_active_dependency", self, "_change_active_depenency")
	_change_active_depenency()


func _change_active_depenency():
	var dependency_id = ui_justification_holder.get_active_dependency()
	for child in ui_dependencies.get_children():
		if child.get_index() == dependency_id:
			child.show()
		else:
			child.hide()
	_update_justification_label()


enum ProofStatus {PROVEN, JUSTIFIED, UNPROVEN}


func _connect_justification_label():
	proof_step.connect("justification_type_changed", self, "_update_justification_label")
	proof_step.connect("justification_properties_changed", self, "_update_justification_label")
	proof_step.connect("child_proven", self, "_update_justification_label")
	_update_justification_label()


func _update_justification_label():
	var icon : String
	if not proof_step.is_justification_valid():
		icon = "x"
	elif proof_step.is_proven_except(ui_justification_holder.get_active_dependency()):
		icon = ""
	else:
		icon = "!"
	ui_justification_label.set_text(proof_step.get_justification().get_justification_text(), icon)


func is_proven() -> bool:
	return proof_step.is_proven()


# SELECTION ===============================================


func _on_ui_statement_selected(locator:Locator):
	selection_handler.locator_changed(locator, self)
	ui_justification_holder.locator_changed(locator)

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
