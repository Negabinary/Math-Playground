extends Node
class_name SelectionHandler

signal locator_changed

var wpb

func take_selection(wpb):
	if self.wpb != null and self.wpb != wpb:
		self.wpb.deselect()
	self.wpb = wpb
	if wpb != null:
		wpb.select()
	emit_signal("locator_changed", get_locator())

func locator_changed(x, wpb):
	if self.wpb != null and self.wpb != wpb:
		self.wpb.deselect()
	self.wpb = wpb
	if wpb != null:
		wpb.select()
	emit_signal("locator_changed", get_locator())

func get_locator() -> Locator:
	if self.wpb:
		return self.wpb.get_selected_locator()
	else:
		return null

func get_selected_goal() -> ExprItem:
	if self.wpb:
		return self.wpb.get_goal()
	else:
		return null

func get_selected_proof_box() -> SymmetryBox:
	if self.wpb:
		return self.wpb.get_inner_proof_box()
	else:
		return null

func get_wpb():
	return wpb
