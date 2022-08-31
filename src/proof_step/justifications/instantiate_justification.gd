extends Justification
class_name InstantiateJustification


var new_type : ExprItemType
var existential : ExprItem


func _init(new_type_name:="x", existential_fact=null):
	self.new_type = ExprItemType.new(new_type_name)
	self.existential = existential_fact


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="InstantiateJustification",
		new_type=new_type.to_string(),
		existential=parse_box.serialise(existential)
	}


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	if existential == null:
		return null
	if existential.get_type() != GlobalTypes.EXISTS:
		return null
	var reqs = [Requirement.new(existential)]
	var old_type := existential.get_child(0).get_type()
	var new_assumption = existential.get_child(1).deep_replace_types({old_type:ExprItem.new(new_type)})
	reqs.append(Requirement.new(
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
	if existential == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("expression missing"), true))
	if existential.get_type() != GlobalTypes.EXISTS:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("expression must be an existential"), true))
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
