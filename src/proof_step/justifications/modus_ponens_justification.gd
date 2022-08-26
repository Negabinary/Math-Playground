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
	options.append(Justification.LabelOption.new("Implication:"))
	var eio := Justification.ExprItemOption.new(implication, context)
	eio.connect("expr_item_changed", self, "set_implication")
	options.append(eio)
	if implication == null:
		options.append(Justification.LabelOption.new("Implication missing!", true))
		return options
	var statement = Statement.new(implication)
	if not expr_item.compare(statement.get_conclusion().get_expr_item()):
		options.append(Justification.LabelOption.new("Implication conclusion does not match goal.", true))
	if statement.get_definitions().size() != 0:
		options.append(Justification.LabelOption.new("Implication must not have quantifiers.", true))
	return options


func get_justification_text(parse_box:AbstractParseBox):
	if implication:
		return "using " + parse_box.printout(implication) + ","
	else:
		return "using an implication,"
