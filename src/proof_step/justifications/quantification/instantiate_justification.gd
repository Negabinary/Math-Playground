extends Justification
class_name InstantiateJustification


var new_type : ExprItemType
var existential : ExprItem


func _init(new_type="x", existential_fact=null):
	if new_type is String:
		self.new_type = ExprItemType.new(new_type)
	elif new_type is ExprItemType:
		self.new_type = new_type
	else:
		self.new_type = ExprItemType.new("???")
	self.existential = existential_fact


func deep_replace_types(matching:Dictionary) -> Justification:
	return get_script().new(
		new_type,
		existential.deep_replace_types(matching) if existential else null
	)


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="InstantiateJustification",
		new_type=new_type.to_string(),
		existential=parse_box.serialise(existential)
	}


func get_requirements_for(expr_item:ExprItem):
	if existential == null:
		return null
	if existential.get_type() != GlobalTypes.EXISTS:
		return null
	var reqs = [Requirement.new(existential)]
	var old_type := existential.get_child(0).get_type()
	var new_assumption = existential.get_child(1).deep_replace_types({old_type:ExprItem.new(new_type)})
	reqs.push_front(Requirement.new(
		expr_item,
		[new_type],
		[new_assumption]
	))
	return reqs


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	var options = []
	options.append(Justification.LabelOption.new(ConstantAutostring.new("Existential: ")))
	var eio := Justification.ExprItemOption.new(existential, context)
	eio.connect("expr_item_changed", self, "set_existential_fact")
	options.append(eio)
	if existential == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Existential missing!"), true))
		return options
	if existential.get_type() != GlobalTypes.EXISTS:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("expression must be an existential"), true))
		return options
	options.append(Justification.LabelOption.new(ConstantAutostring.new("Name for new instance: ")))
	options.append(Justification.ExprItemTypeNameOption.new(new_type))
	return options


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	if existential:
		return ConcatAutostring.new(["using ", ExprItemAutostring.new(existential, parse_box), ","])
	else:
		return ConstantAutostring.new("using an existential,")


func set_existential_fact(existential_fact:ExprItem):
	self.existential = existential_fact
	emit_signal("updated")


func get_summary(expr_item:ExprItem, context:AbstractParseBox) -> Array:
	if existential == null:
		return [ConstantAutostring.new("error: existential missing!")]
	if existential.get_type() != GlobalTypes.EXISTS:
		return [ConstantAutostring.new("error: existential missing!")]
	else:
		return [
			ConstantAutostring.new("having used"),
			[1,ConstantAutostring.new("an existential")],
			ConstantAutostring.new("to prove"),
			[0,ConstantAutostring.new("an expression")]
		]


func _get_all_types() -> Dictionary:
	if existential:
		return existential.get_all_types()
	else:
		return {}
