extends Control
class_name ExprItemEdit


signal selection_changed # Unimplemented
signal expr_item_changed # (valid:bool) # Unimplemented

# set_proof_box
export var editable := true


func set_expr_item(expr_item:ExprItem, proof_box := GlobalTypes.PROOF_BOX) -> void:
	if get_child_count() == 1:
		get_child(0).queue_free()
	var child := ExprItemEditHelper.new(self, expr_item, proof_box)
	add_child(child)
	child.connect("minimum_size_changed", self, "_on_minimum_size_change")


func get_expr_item() -> ExprItem:
	return get_child(0).get_expr_item()


func _on_minimum_size_change():
	set_custom_minimum_size(get_child(0).rect_min_size)
	set_size(get_child(0).rect_size)
