extends Control


signal expr_item_selected


func show_expression(expression:Statement, active:=false) -> void:
	$Definitions.update_definitions(expression.get_definitions())
	$ExpressionTree.update_tree(UniversalLocator.new(expression), active)


func show_locator(locator:UniversalLocator, active:=false) -> void:
	$ExpressionTree.update_tree(locator, active)


func _on_expr_item_selected(locator):
	emit_signal("expr_item_selected", locator)


func get_selected() -> UniversalLocator:
	return $ExpressionTree.get_selected_locator()
