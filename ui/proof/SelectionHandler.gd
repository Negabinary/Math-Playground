extends Node
class_name SelectionHandler

signal locator_changed

var wpb : WPBParent

func take_selection(wpb:WPBParent):
	self.wpb = wpb
	emit_signal("locator_changed", get_locator())

func get_locator() -> Locator:
	return self.wpb.get_selected_locator()

func get_proof_step() -> ProofStep:
	return self.wpb.get_proof_step()

func get_wpb() -> WPBParent:
	return wpb
