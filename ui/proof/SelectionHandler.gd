extends Node
class_name SelectionHandler

signal locator_changed

var wpb

func take_selection(wpb):
	self.wpb = wpb
	emit_signal("locator_changed", get_locator())

func get_locator() -> Locator:
	return self.wpb.get_selected_locator()

func get_selected_goal() -> ExprItem:
	return self.wpb.get_goal()

func get_selected_proof_box() -> ExprItem:
	return self.wpb.get_inner_proof_box()

func get_wpb():
	return wpb
