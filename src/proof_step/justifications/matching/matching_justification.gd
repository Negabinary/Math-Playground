extends Justification
class_name MatchingJustification

var new_type : ExprItemType # option


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="MatchingJustification",
		new_type_name = new_type.get_identifier()
	}


func _init(new_type:ExprItemType):
	if new_type == null:
		self.new_type = ExprItemType.new("???")
	else:
		self.new_type = new_type


func deep_replace_types(matching:Dictionary) -> Justification:
	return get_script().new(
		new_type
	)


func get_requirements_for(expr_item:ExprItem):
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return null
	var lhs := expr_item.get_child(0)
	var rhs := expr_item.get_child(1)
	var lhs_is_binder = lhs.get_type().is_binder() and lhs.get_child_count() == 2
	var rhs_is_binder = rhs.get_type().is_binder() and rhs.get_child_count() == 2
	if lhs_is_binder != rhs_is_binder:
		return null
	if lhs_is_binder:
		if lhs.get_type() != rhs.get_type():
			return null
		var bound_var_l := lhs.get_child(0).get_type()
		var bound_var_r := rhs.get_child(0).get_type()
		return [
			Requirement.new(
				ExprItem.new(
					GlobalTypes.EQUALITY,
					[
						lhs.get_child(1).deep_replace_types({bound_var_l:ExprItem.new(new_type)}),
						rhs.get_child(1).deep_replace_types({bound_var_r:ExprItem.new(new_type)})
					]
				),
				[new_type]
			)
		]
		
	else:
		if lhs.get_child_count() == 0 or rhs.get_child_count() == 0:
			return null
		return [
			Requirement.new(
				ExprItem.new(
					GlobalTypes.EQUALITY,
					[lhs.get_child(lhs.get_child_count()-1), rhs.get_child(rhs.get_child_count()-1)]
				)
			),
			Requirement.new(
				ExprItem.new(
					GlobalTypes.EQUALITY,
					[lhs.abandon_lowest(1), rhs.abandon_lowest(1)]
				)
			)
		]


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return [Justification.LabelOption.new(ConstantAutostring.new("cannot match an expression that is not an equality"), true)]
	var lhs := expr_item.get_child(0)
	var rhs := expr_item.get_child(1)
	var lhs_is_binder = lhs.get_type().is_binder() and lhs.get_child_count() == 2
	var rhs_is_binder = rhs.get_type().is_binder() and rhs.get_child_count() == 2
	if lhs_is_binder != rhs_is_binder:
		return [Justification.LabelOption.new(ConstantAutostring.new("cannot match a binder to a non-binder"), true)]
	if lhs_is_binder:
		if lhs.get_type() != rhs.get_type():
			return [Justification.LabelOption.new(ConstantAutostring.new("cannot match two different binders"), true)]
		return [
			Justification.LabelOption.new(ConstantAutostring.new("variable name:")),
			Justification.ExprItemTypeNameOption.new(new_type)
		]
		
	else:
		if lhs.get_child_count() == 0 or rhs.get_child_count() == 0:
			return [Justification.LabelOption.new(ConstantAutostring.new("cannot match something that is not a function or a binder"), true)]
		return []


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("by matching arguments,")


func get_summary(expr_item:ExprItem, context:AbstractParseBox) -> Array:
	if expr_item.get_type() != GlobalTypes.EQUALITY or expr_item.get_child_count() != 2:
		return [ConstantAutostring.new("error : not an equality")]
	var lhs := expr_item.get_child(0)
	var rhs := expr_item.get_child(1)
	var lhs_is_binder = lhs.get_type().is_binder() and lhs.get_child_count() == 2
	var rhs_is_binder = rhs.get_type().is_binder() and rhs.get_child_count() == 2
	if lhs_is_binder != rhs_is_binder:
		return [ConstantAutostring.new("error : matching binder and non-binder")]
	if lhs_is_binder:
		if lhs.get_type() != rhs.get_type():
			return [ConstantAutostring.new("error : matching different types of binders")]
		return [
			ConstantAutostring.new("by matching two binders")
		]
		
	else:
		if lhs.get_child_count() == 0 or rhs.get_child_count() == 0:
			return [ConstantAutostring.new("error : both sides should be functions")]
		return [
			ConstantAutostring.new("by matching"),
			[1,ConstantAutostring.new("two functions")],
			ConstantAutostring.new("and"),
			[0,ConstantAutostring.new("their applications")]
		]


func _get_all_types() -> Dictionary:
	return {}
