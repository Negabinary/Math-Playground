extends Object
class_name Locator


var root_expr_item : ExprItem
var expr_item : ExprItem
var indeces : Array


func _init(new_root_expr_item, new_indeces:=[], new_expr_item:ExprItem=null):
	root_expr_item = new_root_expr_item
	indeces = new_indeces
	if new_expr_item == null:
		expr_item = new_root_expr_item
	else:
		expr_item = new_expr_item


func get_indeces():
	return indeces


func is_root():
	return indeces == []


func get_root():
	return root_expr_item


func get_expr_item() -> ExprItem:
	return expr_item


func get_child_count() -> int:
	return expr_item.get_child_count()


func get_type() -> ExprItemType:
	return expr_item.get_type()


func get_child(idx:int) -> Locator:
	var new_indeces := indeces.duplicate()
	new_indeces.push_back(idx)
	return get_script().new(expr_item, new_indeces, expr_item.get_child(idx))


func _to_string():
	return expr_item.to_string()
