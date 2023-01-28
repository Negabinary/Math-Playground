extends AbstractEqualityJustification
class_name IntroducedLambdaJustification

func _init(x).(x):
	pass


func deep_replace_types(matching:Dictionary) -> Justification:
	return get_script().new(
		location.deep_replace_types(matching)
	)


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="IntroducedLambdaJustification",
		location_expr_item=parse_box.serialise(location.get_root()),
		location_indeces=location.get_indeces()
	}


func _get_equality_replace_with(what:ExprItem):
	if what.get_type() != GlobalTypes.LAMBDA:
		return null
	if what.get_child_count() < 3:
		return null
	var x := what.get_child(1).deep_replace_types({
		what.get_child(0).get_type() : what.get_child(2).alpha_duplicate()
	})
	var y := what.get_children()
	y.pop_front()
	y.pop_front()
	y.pop_front()
	for z in y:
		x = x.apply(z)
	return x


func _get_equality_requirements(what:ExprItem):
	return []


func _get_equality_options(what:ExprItem, context:AbstractParseBox):
	if what.get_type() != GlobalTypes.LAMBDA:
		return [Justification.LabelOption.new(ConstantAutostring.new("That location is not a lambda expression!"), true)]
	if what.get_child_count() < 3:
		return [Justification.LabelOption.new(ConstantAutostring.new("That lambda is not applied to anything!"), true)]
	return []


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("by introducing a function,")


func _get_all_types() -> Dictionary:
	return location.get_root().get_all_types()
