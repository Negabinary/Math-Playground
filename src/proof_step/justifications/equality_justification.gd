extends AbstractEqualityJustification
class_name EqualityJustification

var replace_with : ExprItem
var forwards : bool


func _init(location:Locator, replace_with=null, forwards:=true).(location):
	self.replace_with = replace_with
	self.forwards = forwards


func serialize() -> Dictionary:
	return {
		justification_version=1,
		justification_type="EqualityJustification",
		location_expr_item=location.get_root().serialize(),
		location_indeces=location.get_indeces(),
		replace_with=replace_with.serialize(),
		forwards=forwards
	}


func _get_equality_replace_with(what:ExprItem, context:AbstractParseBox):
	return replace_with


func _get_equality_requirements(what:ExprItem, context:AbstractParseBox):
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
	options.append(Justification.LabelOption.new("Replace with:"))
	var rw_option := Justification.ExprItemOption.new(replace_with, location.get_parse_box(context))
	rw_option.connect("expr_item_changed", self, "set_replace_with")
	options.append(rw_option)
	return options


func get_justification_text():
	if location and replace_with:
		return "using " + location.get_expr_item().to_string() + " = " + replace_with.to_string() + ", "
	else:
		return "using an equality,"
