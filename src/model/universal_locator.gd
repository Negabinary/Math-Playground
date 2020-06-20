extends Object
class_name UniversalLocator

var statement : Statement
var locator : Locator


func _init(new_statement, new_locator:Locator=null):
	statement = new_statement
	if new_locator == null:
		locator = Locator.new(new_statement.as_expr_item())
	else:
		locator = new_locator


func get_indeces():
	return locator.get_indeces()


func is_root():
	return locator.is_root()


func get_type() -> ExprItemType:
	return locator.get_type()


func get_expr_item() -> ExprItem:
	return locator.get_expr_item()


func get_child_count() -> int:
	return locator.get_child_count()


func get_statement() -> Statement:
	return statement


func get_definitions() -> Array:
	return statement.get_definitions()


func get_child(idx:int) -> UniversalLocator:
	return get_script().new(statement, locator.get_child(idx))


func _to_string():
	return locator.to_string()
