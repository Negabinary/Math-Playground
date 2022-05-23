extends MarginContainer
class_name WrittenProofBox2

onready var WPB2:PackedScene = load("res://ui/proof/written_proof_box/WPB2.tscn")

var inner_proof_box : ProofBox # final
var requirement : Requirement # final
var selection_handler # final

var ui_assumptions : Assumptions
var ui_dependencies : MarginContainer
var ui_justification_label : WrittenJustification
var ui_justification_holder : WPBJustification
var ui_statement : WrittenStatement

var WPB_SCENE = load("res://ui/proof/written_proof_box/WPB2.tscn")


# INITIALISATION ==========================================

func _find_ui_elements() -> void:
	ui_assumptions = $WrittenProofBox/Assumptions
	ui_dependencies = $WrittenProofBox/Dependencies
	ui_justification_label = $WrittenProofBox/JustificationLabel
	ui_justification_holder = $WrittenProofBox/Justification
	ui_statement = $WrittenProofBox/Statement


func init(context:ProofBox, requirement:Requirement, selection_handler):
	_find_ui_elements()
	self.requirement = requirement
	self.selection_handler = selection_handler
	self.inner_proof_box = ProofBox.new(
		context, requirement.get_definitions(), requirement.get_assumptions()
	)
	ui_statement.set_expr_item(requirement.get_goal())
	ui_justification_holder.init(requirement.get_goal(), inner_proof_box, selection_handler)
	ui_justification_holder.connect("justification_changed", self, "_on_justification_changed")
	ui_justification_label.set_text(ui_justification_holder.get_justification_label())
	_change_dependencies(ui_justification_holder.get_requirements())
	if requirement.get_assumptions().size() > 0 or requirement.get_definitions().size() > 0:
		ui_assumptions.display_assumptions(requirement)
	else:
		ui_assumptions.hide()
		add_constant_override("margin_left", 0)
	ui_statement.connect("selection_changed", selection_handler, "locator_changed", [self])
	update()


# STATUS ==================================================

enum ProofStatus {PROVEN, JUSTIFIED, UNPROVEN}

func is_proven() -> int:
	var reqs = ui_justification_holder.get_requirements()
	if reqs == null:
		return ProofStatus.UNPROVEN
	for child in $Dependencies.get_children():
		if not (child.is_proven() == ProofStatus.PROVEN):
			return ProofStatus.JUSTIFIED
	return ProofStatus.PROVEN


func get_goal() -> ExprItem:
	return requirement.get_goal()


func get_inner_proof_box() -> ProofBox:
	return inner_proof_box


func get_selected_locator() -> Locator:
	return ui_statement.get_locator()


# UPDATES =================================================

func _change_dependencies(requirements:Array, dependency_id:=0):
	var keepers := {}
	var old_children = ui_dependencies.get_children()
	for child in ui_dependencies.get_children():
		ui_dependencies.remove_child(child)
	for new_requirement in requirements:
		for child in old_children:
			if child.requirement.compare(new_requirement):
				keepers[new_requirement] = child
				old_children.erase(child)
				break
		if keepers.get(new_requirement):
			ui_dependencies.add_child(keepers[new_requirement])
		else:
			var new_ui_dependency = WPB2.instance()
			new_ui_dependency.init(inner_proof_box, new_requirement, selection_handler)
			ui_dependencies.add_child(new_ui_dependency)
	_change_active_depenency(dependency_id)


func _change_active_depenency(dependency_id:int):
	for child in ui_dependencies.get_children():
		if child.get_index() == dependency_id:
			child.show()
		else:
			child.hide()


func _on_justification_changed():
	_change_dependencies(ui_justification_holder.get_requirements())
	ui_justification_label.set_text(ui_justification_holder.get_justification_label())


# DRAWING =================================================

func _draw():
	var ui_assumptions := $WrittenProofBox/Assumptions
	if requirement.get_assumptions().size() > 0 or requirement.get_definitions().size() > 0:
		var font := get_font("font", "WrittenJustification")
		var half_font_height := font.get_height() / 2
		var color := get_color("font_color", "WrittenJustification")
		var x := 15 + get_constant("margin_left")
		draw_line(Vector2(x, half_font_height), Vector2(x, rect_size.y), color)
		for assumption in ui_assumptions.get_children():
			var y = assumption.rect_position.y + half_font_height
			draw_line(Vector2(x, y), Vector2(x + 10,y), color)
		draw_colored_polygon(PoolVector2Array([
			Vector2(x, rect_size.y),
			Vector2(x-4, rect_size.y-7),
			Vector2(x+4, rect_size.y-7)
		]), color)
