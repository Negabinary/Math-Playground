extends Object
class_name Locator

var expr
var indeces : Array
var expr_item : ExprItem


func _init(new_expr, new_indeces:=[], new_expr_item:ExprItem=null):
	expr = new_expr
	indeces = new_indeces
	if new_expr_item == null:
		expr_item = new_expr.as_expr_item()
	else:
		expr_item = new_expr_item


func is_root():
	return indeces == []


func get_expr_item() -> ExprItem:
	return expr_item


func get_child_count() -> int:
	return expr_item.get_child_count()


func get_expr():
	return expr


func get_child(idx:int) -> Locator:
	var new_indeces := indeces.duplicate()
	new_indeces.push_back(idx)
	return get_script().new(expr, new_indeces, expr_item.get_child(idx))
