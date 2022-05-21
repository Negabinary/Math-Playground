extends AbstractEqualityJustification
class_name EliminatedLambdaJustification


var replace_value : ExprItem
var replace_with : ExprItemType
var replace_locations : Array
var replace_positions : Array


func _init(location:Locator, replace_value = null, replace_with:ExprItemType = ExprItemType.new(""), replace_positions = null).(location):
	self.replace_value = replace_value
	self.replace_with = replace_with
	self.replace_positions = replace_positions


func set_location(location:Locator):
	.set_location(location)
	set_replace_value(replace_value)


func set_replace_value(new_replace_value:ExprItem):
	self.replace_value = new_replace_value
	if replace_value:
		self.replace_locations = Locator.new(location.get_expr_item()).find(replace_value)
		self.replace_positions = []
		for i in replace_locations:
			self.replace_positions.append(true)
	emit_signal("updated")


func set_replace_position(value:bool, index:int):
	self.replace_positions[index] = value
	emit_signal("updated")


# OVERRIDES ===================================================================

func _get_equality_replace_with(what:ExprItem, context:ParseBox):
	if replace_value == null:
		return null
	# TODO: check locations have the right parent
	var new_expr_item = what
	for i in replace_locations.size():
		if replace_positions[i]:
			new_expr_item.replace_at(replace_locations[i].get_indeces(), ExprItem.new(replace_with))
	return ExprItem.new(
		GlobalTypes.LAMBDA,
		[
			ExprItem.new(replace_with),
			new_expr_item,
			replace_value
		]
	)


func _get_equality_requirements(what:ExprItem, context:ParseBox):
	return []


func _get_equality_options(what:ExprItem, context:ParseBox):
	var options = []
	options.append(Justification.LabelOption.new("Replace instances of:"))
	options.append(Justification.ExprItemOption.new(replace_value, context))
	if replace_value == null:
		options.append(Justification.LabelOption("expression missing", true))
	options.append(Justification.LabelOption.new("with a variable called:"))
	options.append(Justification.ExprItemTypeNameOption.new(replace_with))
	if replace_value != null:
		if replace_locations.size() == 0:
			options.append(Justification.LabelOption.new("(this will be a constant function, since the expression above does not appear in the goal)"))
		else:
			options.append(Justification.LabelOption.new("specifically these instances:", true))
			for i in replace_locations.size():
				var boolean_option = Justification.BooleanOption.new(MiscUtil.ordinal(i), replace_positions[i])
				boolean_option.connect("value_changed", self, "set_replace_position", [i])
				options.append(boolean_option)
	return options


func get_justification_text():
	return "APPLYING A FUNCTION"
