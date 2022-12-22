extends AbstractEqualityJustification
class_name EliminatedLambdaJustification


var replace_value : ExprItem
var replace_with : ExprItemType
var replace_positions #: Array

var replace_locations #: Array


func _init(location:Locator, replace_value = null, replace_with:ExprItemType = ExprItemType.new("???"), replace_positions = null).(location):
	self.replace_with = replace_with
	self.replace_value = replace_value
	if replace_value:
		self.replace_locations = Locator.new(location.get_expr_item()).find_all(replace_value)
		self.replace_positions = []
		for i in replace_locations:
			self.replace_positions.append(true)
	self.replace_positions = replace_positions


func set_location(location:Locator):
	.set_location(location)
	set_replace_value(replace_value)


func set_replace_value(new_replace_value:ExprItem):
	self.replace_value = new_replace_value
	if replace_value:
		self.replace_locations = Locator.new(location.get_expr_item()).find_all(replace_value)
		self.replace_positions = []
		for i in replace_locations:
			self.replace_positions.append(true)
	emit_signal("updated")


func set_replace_position(value:bool, index:int):
	self.replace_positions[index] = value
	emit_signal("updated")


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="EliminatedLambdaJustification",
		location_expr_item=parse_box.serialise(location.get_root()),
		location_indeces=location.get_indeces(),
		replace_value=location.get_parse_box(parse_box).serialise(replace_value),
		replace_with=replace_with.to_string(),
		replace_positions=replace_positions
	}


# OVERRIDES ===================================================================

func _get_equality_replace_with(what:ExprItem):
	if replace_value == null:
		return null
	# TODO: check locations have the right parent
	var new_expr_item = what
	for i in replace_locations.size():
		if replace_positions[i]:
			new_expr_item = new_expr_item.replace_at(replace_locations[i].get_indeces(), replace_locations[i].get_abandon(), ExprItem.new(replace_with))
	return ExprItem.new(
		GlobalTypes.LAMBDA,
		[
			ExprItem.new(replace_with),
			new_expr_item,
			replace_value
		]
	)


func _get_equality_requirements(what:ExprItem):
	return []


func _get_equality_options(what:ExprItem, context:AbstractParseBox):
	var options = []
	options.append(Justification.LabelOption.new(ConstantAutostring.new("Replace instances of:")))
	var eio := Justification.ExprItemOption.new(replace_value, location.get_parse_box(context))
	eio.connect("expr_item_changed", self, "set_replace_value")
	options.append(eio)
	if replace_value == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("expression missing"), true))
	options.append(Justification.LabelOption.new(ConstantAutostring.new("with a variable called:")))
	options.append(Justification.ExprItemTypeNameOption.new(replace_with))
	if replace_value != null:
		if replace_locations.size() == 0:
			options.append(Justification.LabelOption.new(ConstantAutostring.new("(this will be a constant function, since the expression above does not appear in the goal)")))
		else:
			options.append(Justification.LabelOption.new(ConstantAutostring.new("specifically these instances:")))
			for i in replace_locations.size():
				var boolean_option = Justification.BooleanOption.new(ConstantAutostring.new(MiscUtil.ordinal(i)), replace_positions[i])
				boolean_option.connect("value_changed", self, "set_replace_position", [i])
				options.append(boolean_option)
	return options


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("by applying that function,")


func _get_all_types() -> Dictionary:
	return _combine_all_types(
		location.get_root().get_all_types(),
		replace_value.get_all_types() if replace_value else {}
	)
