extends Object
class_name UniversalLocator

var statement
var indeces : Array
var missing_children := 0
var expr_item : ExprItem


func _init(new_expr, new_indeces:=[], new_expr_item:ExprItem=null, new_missing_children:=0):
	statement = new_expr
	indeces = new_indeces
	if new_expr_item == null:
		expr_item = new_expr.as_expr_item()
	else:
		expr_item = new_expr_item
	missing_children = new_missing_children


func is_root():
	return indeces == []


func get_type() -> ExprItemType:
	return expr_item.get_type()


func get_expr_item() -> ExprItem:
	return expr_item


func get_child_count() -> int:
	return expr_item.get_child_count()


func get_statement():
	return statement


func get_definitions() -> Array:
	return statement.get_definitions()


func get_child(idx:int) -> UniversalLocator:
	var new_indeces := indeces.duplicate()
	new_indeces.push_back(idx)
	return get_script().new(statement, new_indeces, expr_item.get_child(idx))


func abandon_lowest(idx:int) -> UniversalLocator:
	assert (idx <= get_child_count())
	return get_script().new(
		statement,
		indeces,
		expr_item.abandon_lowest(idx),
		idx + missing_children
	)


func _to_string():
	return expr_item.to_string()
