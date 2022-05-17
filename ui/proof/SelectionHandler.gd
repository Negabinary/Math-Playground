extends Node
class_name SelectionHandler

signal locator_changed

var wpb : WPBParent

func take_selection(wpb:WPBParent):
	self.wpb = wpb
	emit_signal("locator_changed", get_locator())

func get_locator() -> Locator:
	return self.wpb.get_selected_locator()

func get_selected_goal() -> Requirement:
	return self.wpb.get_requirement()

func get_wpb() -> WPBParent:
	return wpb
