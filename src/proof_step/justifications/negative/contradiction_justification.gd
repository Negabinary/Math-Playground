extends Justification
class_name ContradictionJustification 

var contradiction : ExprItem


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="ContradictionJustification",
		contradiction=parse_box.serialise(contradiction)
	}


func _init(contradiction=null):
	self.contradiction = contradiction
	emit_signal("updated")


func set_contradiction(contradiction:ExprItem):
	self.contradiction = contradiction
	emit_signal("updated")


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	if contradiction == null:
		return null
	if expr_item.get_type() != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return null
	return [
		Requirement.new(
			contradiction,
			[],
			[expr_item.get_child(0)]
		),
		Requirement.new(
			ExprItem.new(GlobalTypes.NOT, [contradiction]),
			[],
			[expr_item.get_child(0)]
		)
	]


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	var options = []
	if expr_item.get_type() != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Contradiction can only be used to prove negative statements!"), true))
		return options
	options.append(Justification.LabelOption.new(ConstantAutostring.new("Contradiction on:")))
	var eio := Justification.ExprItemOption.new(contradiction, context)
	eio.connect("expr_item_changed", self, "set_contradiction")
	options.append(eio)
	if contradiction  == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Contradiction term missing!"), true))
		return options
	return options


func get_summary(expr_item:ExprItem, context:AbstractParseBox) -> Array:
	if expr_item.get_type() != GlobalTypes.NOT or expr_item.get_child_count() != 1:
		return [ConstantAutostring.new("error: not a negative!")]
	if contradiction == null:
		return [ConstantAutostring.new("error: missing contradiction term")]
	return [
		ConstantAutostring.new("by contradiction, showing a statement to both"),
		[0,ConstantAutostring.new("true")],
		ConstantAutostring.new("and"),
		[1,ConstantAutostring.new("false")]
	]
