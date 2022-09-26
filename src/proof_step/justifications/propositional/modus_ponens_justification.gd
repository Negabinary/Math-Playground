extends Justification
class_name ModusPonensJustification

# TODO: Partial Modus Ponenses
var implication : ExprItem


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="ModusPonensJustification",
		implication=parse_box.serialise(implication)
	}


func _init(implication=null):
	self.implication = implication
	emit_signal("updated")


func set_implication(implication:ExprItem):
	self.implication = implication
	emit_signal("updated")


func get_requirements_for(expr_item:ExprItem, parse_box:AbstractParseBox):
	if implication == null:
		return null
	var statement = Statement.new(implication)
	if not expr_item.compare(statement.get_conclusion().get_expr_item()):
		return null
	if statement.get_definitions().size() != 0:
		return null
	var reqs := []
	for assumption in statement.get_conditions():
		reqs.append(Requirement.new(
			assumption.get_expr_item()
		))
	reqs.append(Requirement.new(implication))
	return reqs


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	var options = []
	options.append(Justification.LabelOption.new(ConstantAutostring.new("Implication:")))
	var eio := Justification.ExprItemOption.new(implication, context)
	eio.connect("expr_item_changed", self, "set_implication")
	options.append(eio)
	if implication == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Implication missing!"), true))
		return options
	var statement = Statement.new(implication)
	if not expr_item.compare(statement.get_conclusion().get_expr_item()):
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Implication conclusion does not match goal."), true))
	if statement.get_definitions().size() != 0:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Implication must not have quantifiers."), true))
	return options


func get_summary(expr_item:ExprItem, context:AbstractParseBox) -> Array:
	if implication == null:
		return [ConstantAutostring.new("error: missing implication!")]
	var statement = Statement.new(implication)
	if not expr_item.compare(statement.get_conclusion().get_expr_item()):
		return [ConstantAutostring.new("error: implication conclusion does not match goal!")]
	if statement.get_definitions().size() != 0:
		return [ConstantAutostring.new("error: implication must not have quantifiers")]
	var conditions = Statement.new(implication).get_conditions()
	var result = []
	result.append(ConstantAutostring.new("using"))
	result.append([len(conditions), ConstantAutostring.new("this implication,")])
	if len(conditions) > 0:
		result.append(ConstantAutostring.new("if"))
	for i in len(conditions):
		if i > 0:
			result.append(ConstantAutostring.new("and"))
		result.append([i,ExprItemAutostring.new(conditions[i].get_expr_item(), context)])
	if len(conditions) > 0:
		result.append(ConcatAutostring.new(["then ", ExprItemAutostring.new(statement.get_conclusion().get_expr_item(), context)]))
	return result


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	if implication:
		return ConcatAutostring.new(["using ", ExprItemAutostring.new(implication, parse_box), ","])
	else:
		return ConstantAutostring.new("using an implication,")


func _get_all_types() -> Dictionary:
	return implication.get_all_types()
