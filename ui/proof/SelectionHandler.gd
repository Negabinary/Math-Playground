extends Node
class_name SelectionHandler


# JANK ====================================================

var assumption_pane


# WPB =====================================================

var wpb
signal wpb_changed


func get_wpb():
	if is_instance_valid(wpb):
		return wpb
	else:
		return null


func get_selected_proof_box() -> SymmetryBox:
	if get_wpb():
		return wpb.get_inner_proof_box()
	else:
		return null


func get_selected_goal() -> ExprItem:
	if get_wpb():
		return wpb.get_goal()
	else:
		return null


func set_wpb(new_wpb):
	if wpb != new_wpb:
		if get_wpb():
			self.wpb.deselect()
			if wpb.is_connected("tree_exiting", self, "clear_wpb"):
				wpb.disconnect("now_has_dependencies", self, "_on_selected_gain_dependencies")
				wpb.disconnect("tree_exiting", self, "clear_wpb")
				wpb.get_proof_step().disconnect("justification_type_changed", self, "_on_selected_justified")
		wpb = new_wpb
		if new_wpb:
			wpb.select()
			new_wpb.connect("now_has_dependencies", self, "_on_selected_gain_dependencies")
			new_wpb.connect("tree_exiting", self, "clear_wpb")
			new_wpb.get_proof_step().connect("justification_type_changed", self, "_on_selected_justified")
	emit_signal("wpb_changed")
	emit_signal("justification_changed")


func clear_wpb():
	set_wpb(null)


# Locator =================================================

signal locator_changed

func get_locator() -> Locator:
	if get_wpb():
		return wpb.get_selected_locator()
	else:
		return null


func locator_changed(x, wpb):
	set_wpb(wpb)
	emit_signal("locator_changed", get_locator())


# Justification ===========================================

signal justification_changed


func _on_selected_gain_dependencies():
	while wpb.get_wpb_child(wpb.get_proof_step().get_active_dependency()):
		wpb.get_wpb_child(wpb.get_proof_step().get_active_dependency()).take_selection()
	emit_signal("justification_changed")


func _on_selected_justified():
	emit_signal("justification_changed")


func get_justification() -> Justification:
	if get_wpb():
		return wpb.get_proof_step().get_justification()
	else:
		return null
