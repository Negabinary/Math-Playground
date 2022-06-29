extends ActionButton
class_name InstantiateButton


func _should_display() -> bool:
	return assumption.get_conclusion().get_type() == GlobalTypes.EXISTS and assumption.get_definitions().size() == 0


func _can_use() -> bool:
	return true


func _on_pressed():
	var existential = assumption.get_conclusion().get_expr_item()
	var existential_justification = InstantiateJustification.new(
		existential.get_child(0).get_type().to_string(),
		existential
	)
	var modus_ponens = ModusPonensJustification.new(
		assumption
	)
	selection_handler.get_selected_proof_box().add_justification(selection_handler.get_locator().get_root(), existential_justification)
	selection_handler.get_selected_proof_box().add_justification(existential, modus_ponens)
