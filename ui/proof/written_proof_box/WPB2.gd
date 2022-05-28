extends MarginContainer
class_name WrittenProofBox2

signal validity_changed

var inner_proof_box : ProofBox # final
var requirement : Requirement # final
var selection_handler # final

var ui_statement : WrittenStatement
var ui_justification_holder : WPBJustification
var ui_justification_label : WrittenJustification
var ui_dependencies : MarginContainer
var ui_assumptions : Assumptions

var valid := false


var WPB_SCENE = load("res://ui/proof/written_proof_box/WPB2.tscn")


# INITIALISATION ==========================================

func init(context:ProofBox, requirement:Requirement, selection_handler):
	self.requirement = requirement
	self.selection_handler = selection_handler
	selection_handler.connect("locator_changed", self, "_on_selected_locator_changed")
	self.inner_proof_box = ProofBox.new(
		context, requirement.get_definitions(), requirement.get_assumptions()
	)
	_find_ui_elements()
	ui_justification_holder.init(requirement.get_goal(), inner_proof_box, selection_handler)
	_connect_dependencies()
	_connect_active_dependency()
	_connect_justification_label()
	ui_statement.set_expr_item(requirement.get_goal())
	if requirement.get_assumptions().size() > 0 or requirement.get_definitions().size() > 0:
		ui_assumptions.display_assumptions(requirement)
	else:
		ui_assumptions.hide()
		add_constant_override("margin_left", 0)
	ui_statement.connect("selection_changed", selection_handler, "locator_changed", [self])
	update()


func _find_ui_elements() -> void:
	ui_statement = $WrittenProofBox/Statement
	ui_justification_holder = $WrittenProofBox/Justification
	ui_justification_label = $WrittenProofBox/JustificationLabel
	ui_dependencies = $WrittenProofBox/Dependencies
	ui_assumptions = $WrittenProofBox/Assumptions


# GETTERS ==================================================


func get_goal() -> ExprItem:
	return requirement.get_goal()


func get_inner_proof_box() -> ProofBox:
	return inner_proof_box


func get_selected_locator() -> Locator:
	return ui_statement.get_locator()


# DEPENDENCIES =================================================

func _connect_dependencies():
	ui_justification_holder.connect("justification_changed", self, "_change_dependencies")
	_change_dependencies()


func _change_dependencies():
	var keepers := {}
	var requirements = ui_justification_holder.get_requirements()
	var old_children = ui_dependencies.get_children()
	for child in ui_dependencies.get_children():
		child.disconnect("validity_changed", self, "_update_justification_label")
		ui_dependencies.remove_child(child)
	for new_requirement in requirements:
		for child in old_children:
			if child.requirement.compare(new_requirement):
				keepers[new_requirement] = child
				old_children.erase(child)
				break
		if keepers.get(new_requirement):
			keepers[new_requirement].connect("validity_changed", self, "_update_justification_label")
			ui_dependencies.add_child(keepers[new_requirement])
		else:
			var new_ui_dependency = WPB_SCENE.instance()
			new_ui_dependency.connect("validity_changed", self, "_update_justification_label")
			new_ui_dependency.init(inner_proof_box, new_requirement, selection_handler)
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


enum ProofStatus {PROVEN, JUSTIFIED, UNPROVEN}


func _connect_justification_label():
	ui_justification_holder.connect("justification_changed", self, "_update_justification_label")
	_update_justification_label()


func _update_justification_label():
	var icon : String
	var proven := is_proven()
	match proven:
		ProofStatus.PROVEN:
			icon = ""
			if not valid:
				valid = true
			emit_signal("validity_changed")
		ProofStatus.JUSTIFIED:
			icon = "!"
			if valid:
				valid = false
			emit_signal("validity_changed")
		ProofStatus.UNPROVEN:
			icon = "x"
			if valid:
				valid = false
			emit_signal("validity_changed")
	ui_justification_label.set_text(ui_justification_holder.get_justification_label(), icon)


func is_proven() -> int:
	if not ui_justification_holder.get_is_valid():
		return ProofStatus.UNPROVEN
	for child in ui_dependencies.get_children():
		if not (child.is_proven() == ProofStatus.PROVEN):
			return ProofStatus.JUSTIFIED
	return ProofStatus.PROVEN
	


func _on_selected_locator_changed(locator):
	if selection_handler.get_wpb() != self:
		ui_statement.deselect()


# DRAWING =================================================

func _draw():
	var ui_assumptions := $WrittenProofBox/Assumptions
	if requirement.get_assumptions().size() > 0 or requirement.get_definitions().size() > 0:
		var font := get_font("font", "WrittenJustification")
		var half_font_height := font.get_height() / 2
		var color := get_color("font_color", "WrittenJustification")
		var x := 5 + get_constant("margin_left")
		draw_line(Vector2(x, half_font_height), Vector2(x, rect_size.y), color)
		for assumption in ui_assumptions.get_children():
			var y = assumption.rect_position.y + half_font_height
			draw_line(Vector2(x, y), Vector2(x + 10,y), color)
		draw_colored_polygon(PoolVector2Array([
			Vector2(x, rect_size.y),
			Vector2(x-4, rect_size.y-7),
			Vector2(x+4, rect_size.y-7)
		]), color)
