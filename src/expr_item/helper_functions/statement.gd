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
			or (locator.get_type() == GlobalTypes.IMPLIES and locator.get_child_count() == 2)):
		while locator.get_type() == GlobalTypes.FORALL:
			definitions.append(locator.get_child(0).get_type())
			locator = locator.get_child(1)
		while locator.get_type() == GlobalTypes.IMPLIES and locator.get_child_count() == 2:
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


func construct_without(keep_definition_ids:Array, keep_condition_ids:Array) -> ExprItem:
	var return_value := conclusion.get_expr_item()
	
	for i in range(conditions.size()-1, -1, -1):
		if i in keep_condition_ids:
			return_value = ExprItem.new(GlobalTypes.IMPLIES, [conditions[i].get_expr_item(), return_value])
	
	for i in range(definitions.size()-1, -1, -1):
		if i in keep_definition_ids:
			return_value = ExprItem.new(GlobalTypes.FORALL, [ExprItem.new(definitions[i]), return_value])
	
	return return_value


func compare_expr_item(ei:ExprItem) -> bool:
	return root.compare(ei)


func get_definitions() -> Array:
	return definitions


func get_conditions() -> Array:
	return conditions


func get_condition_eis() -> Array:
	var condition_eis := []
	for condition in conditions:
		condition_eis.append(condition.get_expr_item())
	return condition_eis


func as_expr_item() -> ExprItem:
	return root


func get_conclusion() -> Locator:
	return conclusion


func _to_string() -> String:
	return root.to_string()


func get_child(idx:int) -> Statement:
	return get_script().new(as_expr_item().get_child(idx))
