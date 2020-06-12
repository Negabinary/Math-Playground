extends Object
class_name Assumption


# TODO: Jusification
# TODO: Assumed Modules
var expression : Expr
var conditions : Array # <Locator>
var definitions : Array # <ExprItemType>
var conclusion : Locator


func _init(new_root:ExprItem, new_definitions:=[]): 
	expression = Expr.new(new_root, new_definitions)
	definitions = []
	conditions = []
	var locator := Locator.new(self)
	while (
			locator.get_expr_item().get_type() == GlobalTypes.FORALL 
			or locator.get_expr_item().get_type() == GlobalTypes.IMPLIES):
		while locator.get_expr_item().get_type() == GlobalTypes.FORALL:
			definitions.append(locator.get_child(0).get_expr_item().get_type())
			locator = locator.get_child(1)
		while locator.get_expr_item().get_type() == GlobalTypes.IMPLIES:
			conditions.append(locator.get_child(0))
			locator = locator.get_child(1)
	conclusion = locator


func get_definitions() -> Array:
	return definitions


func get_conditions() -> Array:
	return conditions


func as_expr_item() -> ExprItem:
	return expression.get_root()


func get_conclusion() -> Locator:
	return conclusion


func _to_string() -> String:
	return expression.to_string()


func get_child(idx:int) -> Assumption:
	return get_script().new(as_expr_item().get_child(idx))
