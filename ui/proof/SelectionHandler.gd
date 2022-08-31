extends Node
class_name SelectionHandler

signal locator_changed

var wpb

func take_selection(wpb):
	if is_instance_valid(self.wpb) and self.wpb != null and self.wpb != wpb:
		self.wpb.disconnect("tree_exiting", self, "deselect")
		self.wpb.deselect()
	self.wpb = wpb
	if wpb != null:
		wpb.select()
	emit_signal("locator_changed", get_locator())
	if not wpb.is_connected("tree_exiting", self, "deselect"):
		wpb.connect("tree_exiting", self, "deselect")

func deselect():
	take_selection(null)

func locator_changed(x, wpb):
	if is_instance_valid(self.wpb) and self.wpb != null and self.wpb != wpb:
		self.wpb.deselect()
	self.wpb = wpb
	if wpb != null:
		wpb.select()
	emit_signal("locator_changed", get_locator())

func get_locator() -> Locator:
	if is_instance_valid(self.wpb) and self.wpb:
		return self.wpb.get_selected_locator()
	else:
		return null

func get_selected_goal() -> ExprItem:
	if is_instance_valid(self.wpb) and self.wpb:
		return self.wpb.get_goal()
	else:
		return null

func get_selected_proof_box() -> SymmetryBox:
	if is_instance_valid(self.wpb) and self.wpb:
		return self.wpb.get_inner_proof_box()
	else:
		return null

func get_wpb():
	return wpb
