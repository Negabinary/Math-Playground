extends Object
class_name Statement


var root : ExprItem
var conditions : Array # <Locator>
var definitions : Array # <ExprItemType>
var conclusions : Array # <Locator>
var conclusion : Locator


func _init(new_root:ExprItem): 
	root = new_root
	definitions = []
	conditions = []
	conclusions = []
	var locator := Locator.new(root)
	while (
			locator.get_type() == GlobalTypes.FORALL 
			or (locator.get_type() == GlobalTypes.IMPLIES and locator.get_child_count() == 2)):
		while locator.get_type() == GlobalTypes.FORALL:
			definitions.append(locator.get_child(0).get_type())
			locator = locator.get_child(1)
		while locator.get_type() == GlobalTypes.IMPLIES and locator.get_child_count() == 2:
			var condition_locators := [locator.get_child(0)]
			while len(condition_locators) != 0:
				var cl:Locator = condition_locators.pop_front()
				if cl.get_type() == GlobalTypes.AND:
					condition_locators.push_front(cl.get_child(1))
					condition_locators.push_front(cl.get_child(0)) 
				else:
					conditions.append(cl)
			locator = locator.get_child(1)
	var queue := [locator]
	while len(queue) != 0:
		var cl:Locator = queue.pop_front()
		if cl.get_type() == GlobalTypes.AND:
			queue.push_front(cl.get_child(1))
			queue.push_front(cl.get_child(0))
		else:
			conclusions.append(cl)
	conclusion = locator


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


func get_conclusion_with_conditions() -> ExprItem:
	var rv := conclusion.get_expr_item()
	conditions.invert()
	for condition in conditions:
		rv = ExprItem.new(
			GlobalTypes.IMPLIES,
			[condition.get_expr_item(), rv]
		)
	conditions.invert()
	return rv


func _to_string() -> String:
	return root.to_string()


func get_child(idx:int) -> Statement:
	return get_script().new(as_expr_item().get_child(idx))
