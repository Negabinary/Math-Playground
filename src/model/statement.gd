extends Object
class_name Statement


# TODO: Jusification
# TODO: Assumed Modules
var root : ExprItem
var conditions : Array # <UniversalLocator>
var definitions : Array # <ExprItemType>
var conclusion : UniversalLocator


func _init(new_root:ExprItem, new_definitions:=[]): 
	root = new_root
	definitions = []
	conditions = []
	var locator := UniversalLocator.new(self)
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
	return root


func get_conclusion() -> UniversalLocator:
	return conclusion


func _to_string() -> String:
	return root.to_string()


func get_child(idx:int) -> Statement:
	return get_script().new(as_expr_item().get_child(idx))
