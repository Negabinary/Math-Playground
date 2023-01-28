extends Justification
class_name OneOfJustification 

var keep_ids : Array # <int>

func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="OneOfJustification",
		keep_ids=keep_ids
	}


func _init(keep_ids:Array):
	self.keep_ids = keep_ids
	emit_signal("updated")


func deep_replace_types(matching:Dictionary) -> Justification:
	return get_script().new(
		keep_ids
	)


func set_keep_id(value, id):
	keep_ids[id] = value
	emit_signal("updated")


func _get_clauses(expr_item:ExprItem) -> Array: #<ExprItem>
	var exploring := [expr_item]
	var final_options := []
	while exploring.size() > 0:
		var next:ExprItem = exploring.pop_front()
		if next.get_type() == GlobalTypes.OR and next.get_child_count() == 2:
			exploring.push_front(next.get_child(1))
			exploring.push_front(next.get_child(0))
		else:
			final_options.append(next)
	return final_options


var _btk_current_index : int
func _build_to_keep(expr_item:ExprItem):
	if expr_item.get_type() == GlobalTypes.OR and expr_item.get_child_count() == 2:
		var lhs = _build_to_keep(expr_item.get_child(0))
		var rhs = _build_to_keep(expr_item.get_child(1))
		if lhs == null and rhs == null:
			return null
		if lhs == null:
			return rhs
		if rhs == null:
			return lhs
		else:
			return ExprItem.new(GlobalTypes.OR, [lhs, rhs])
	else:
		if keep_ids[_btk_current_index]:
			_btk_current_index += 1
			return expr_item
		else:
			_btk_current_index += 1
			return null


func get_requirements_for(expr_item:ExprItem):
	_btk_current_index = 0
	var to_keep = _build_to_keep(expr_item)
	if to_keep == null:
		return null
	return [Requirement.new(
		to_keep
	)]


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	var clauses = _get_clauses(expr_item)
	var options := []
	for clause_id in len(clauses):
		var new_button = Justification.BooleanOption.new(
			ExprItemAutostring.new(clauses[clause_id], context),
			keep_ids[clause_id]
		)
		new_button.connect("value_changed", self, "set_keep_id", [clause_id])
		options.append(new_button)
	_btk_current_index = 0
	var to_keep = _build_to_keep(expr_item)
	if to_keep == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("No clauses selected!"), true))
	return options


func get_summary(expr_item:ExprItem, context:AbstractParseBox) -> Array:
	_btk_current_index = 0
	var to_keep = _build_to_keep(expr_item)
	if to_keep == null:
		return [ConstantAutostring.new("error : no clauses selected!")]
	else:
		return [ConstantAutostring.new("which is one clause of:")]


func _get_all_types() -> Dictionary:
	return {}
