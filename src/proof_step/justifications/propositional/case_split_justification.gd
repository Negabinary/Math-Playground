extends Justification
class_name CaseSplitJustification 

var disjunction : ExprItem


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="CaseSplitJustification",
		disjunction=parse_box.serialise(disjunction)
	}


func _init(disjunction=null):
	self.disjunction = disjunction
	emit_signal("updated")


func deep_replace_types(matching:Dictionary) -> Justification:
	return get_script().new(
		disjunction.deep_replace_types(matching) if disjunction else null
	)


func set_disjunction(disjunction:ExprItem):
	self.disjunction = disjunction
	emit_signal("updated")


func get_clauses() -> Array: #<ExprItem>
	var exploring := [disjunction]
	var final_options := []
	while exploring.size() > 0:
		var next:ExprItem = exploring.pop_front()
		if next.get_type() == GlobalTypes.OR and next.get_child_count() == 2:
			exploring.push_front(next.get_child(1))
			exploring.push_front(next.get_child(0))
		else:
			final_options.append(next)
	return final_options


func get_requirements_for(expr_item:ExprItem):
	if disjunction == null:
		return null
	var requirements := []
	for clause in get_clauses():
		requirements.append(
			Requirement.new(
				expr_item,
				[],
				[clause]
			)
		)
	requirements.append(Requirement.new(disjunction))
	return requirements


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	var options = []
	options.append(Justification.LabelOption.new(ConstantAutostring.new("Disjunction:")))
	var eio := Justification.ExprItemOption.new(disjunction, context)
	eio.connect("expr_item_changed", self, "set_disjunction")
	options.append(eio)
	if disjunction == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Disjunction missing!"), true))
		return options
	var clauses = get_clauses()
	options.append(Justification.LabelOption.new(ConstantAutostring.new("This disjunction has " + str(clauses.size()) + " cases.")))
	return options


func get_summary(expr_item:ExprItem, context:AbstractParseBox) -> Array:
	if disjunction == null:
		return [ConstantAutostring.new("error: missing disjunction!")]
	var cases := get_clauses()
	var result := []
	result.append(ConstantAutostring.new("case splitting on"))
	result.append([len(cases),ConstantAutostring.new("this disjunction,")])
	result.append(ConstantAutostring.new("where"))
	for i in len(cases):
		if i > 0:
			result.append(ConstantAutostring.new("or"))
		result.append([i,ExprItemAutostring.new(cases[i], context)])
	return result


func _get_all_types() -> Dictionary:
	if disjunction:
		return disjunction.get_all_types()
	else:
		return {}
