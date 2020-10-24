extends Object
class_name Statement


var root : ExprItem
var conditions : Array # <UniversalLocator>
var definitions : Array # <ExprItemType>
var conclusion : Locator


func _init(new_root:ExprItem): 
	root = new_root
	definitions = []
	conditions = []
	var locator := Locator.new(root)
	while (
			locator.get_type() == GlobalTypes.FORALL 
			or locator.get_type() == GlobalTypes.IMPLIES):
		while locator.get_type() == GlobalTypes.FORALL:
			definitions.append(locator.get_child(0).get_type())
			locator = locator.get_child(1)
		while locator.get_type() == GlobalTypes.IMPLIES:
			conditions.append(locator.get_child(0))
			locator = locator.get_child(1)
	conclusion = locator


func deep_replace_types(replacements:Dictionary, additional_definitions:=[]) -> Statement: # <ExprItemType, ExprItem>; <ExprItemType>
	var new_definitions := definitions.duplicate()
	for sub_def in replacements:
		new_definitions.erase(sub_def)
	for add_def in additional_definitions:
		new_definitions.append(add_def)
	
	var new_conditions := [] # <ExprItem>
	for condition in conditions:
		new_conditions.append(condition.get_expr_item().deep_replace_types(replacements))
	
	var new_conclusion := conclusion.get_expr_item().deep_replace_types(replacements)
	
	var new_expr_item := new_conclusion
	for new_condition in new_conditions:
		new_expr_item = ExprItem.new(GlobalTypes.IMPLIES, [new_condition, new_expr_item])
	for new_definition in new_definitions:
		new_expr_item = ExprItem.new(GlobalTypes.FORALL, [ExprItem.new(new_definition), new_expr_item])
	
	return get_script().new(new_expr_item)


func get_definitions() -> Array:
	return definitions


func get_conditions() -> Array:
	return conditions


func as_expr_item() -> ExprItem:
	return root


func get_conclusion() -> Locator:
	return conclusion


func _to_string() -> String:
	return root.to_string()


func get_child(idx:int) -> Statement:
	return get_script().new(as_expr_item().get_child(idx))
