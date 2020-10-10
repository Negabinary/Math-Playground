extends Object
class_name Tag


var expr_item : ExprItem
var parameters : Array #<ExprItemType>

func _init(expr_item:ExprItem, parameters:=[]) -> void:
	self.expr_item = expr_item
	self.parameters = parameters

func get_expr_item() -> ExprItem:
	return expr_item

func get_parameters() -> Array:
	return parameters

func _to_string():
	return expr_item.to_string()
