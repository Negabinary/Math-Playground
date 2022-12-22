extends Justification
class_name CombineJustification 


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="CombineJustification",
	}


func _get_clauses(expr_item:ExprItem) -> Array: #<ExprItem>
	var exploring := [expr_item]
	var final_options := []
	while exploring.size() > 0:
		var next:ExprItem = exploring.pop_front()
		if next.get_type() == GlobalTypes.AND and next.get_child_count() == 2:
			exploring.push_front(next.get_child(1))
			exploring.push_front(next.get_child(0))
		else:
			final_options.append(next)
	return final_options


func get_requirements_for(expr_item:ExprItem):
	var requirements := []
	for clause in _get_clauses(expr_item):
		requirements.append(
			Requirement.new(
				clause
			)
		)
	return requirements


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	return []


func get_summary(expr_item:ExprItem, context:AbstractParseBox) -> Array:
	var cases := _get_clauses(expr_item)
	var result := []
	result.append(ConstantAutostring.new("combining"))
	for i in len(cases):
		if i > 0:
			result.append(ConstantAutostring.new("and"))
		result.append([i,ExprItemAutostring.new(cases[i], context)])
	return result


func _get_all_types() -> Dictionary:
	return {}
