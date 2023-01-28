extends AbstractEqualityJustification
class_name EqualityJustification

var replace_with : ExprItem
var forwards : bool


func _init(location:Locator, replace_with=null, forwards:=true).(location):
	self.replace_with = replace_with
	self.forwards = forwards


func deep_replace_types(matching:Dictionary) -> Justification:
	return get_script().new(
		location.deep_replace_types(matching),
		replace_with.deep_replace_types(matching) if replace_with else null,
		forwards
	)


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="EqualityJustification",
		location_expr_item=parse_box.serialise(location.get_root()),
		location_indeces=location.get_indeces(),
		replace_with=location.get_parse_box(parse_box).serialise(replace_with),
		forwards=forwards
	}


func _get_equality_replace_with(what:ExprItem):
	return replace_with


func _get_equality_requirements(what:ExprItem):
	if replace_with == null:
		return null
	if forwards:
		return [Requirement.new(ExprItem.new(
			GlobalTypes.EQUALITY,
			[replace_with, what]
		), location.get_outside_definitions())]
	else:
		return [Requirement.new(ExprItem.new(
			GlobalTypes.EQUALITY,
			[what, replace_with]
		), location.get_outside_definitions())]


func set_replace_with(rw:ExprItem):
	self.replace_with = rw
	emit_signal("updated")


func _get_equality_options(what:ExprItem, context:AbstractParseBox):
	var options = []
	options.append(Justification.LabelOption.new(ConstantAutostring.new("Replace with:")))
	var rw_option := Justification.ExprItemOption.new(replace_with, location.get_parse_box(context))
	rw_option.connect("expr_item_changed", self, "set_replace_with")
	options.append(rw_option)
	if replace_with == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Missing replacement!"), true))
	return options


func get_summary(expr_item:ExprItem, context:AbstractParseBox) -> Array:
	if location == null or (not expr_item.compare(location.get_root())):
		return [ConstantAutostring.new("error: invalid location")]
	if replace_with == null:
		return [ConstantAutostring.new("error: no replacement")]
	else:
		return [
			ConstantAutostring.new("substituting"),
			[1,ConstantAutostring.new("an equality")],
			ConstantAutostring.new("into"),
			[0,ConstantAutostring.new("an expression")]
		]

func _get_all_types() -> Dictionary:
	return _combine_all_types(
		location.get_root().get_all_types(),
		_remove_types_from(
			location.get_outside_definitions(),
			replace_with.get_all_types() if replace_with else {}
		)
	)
