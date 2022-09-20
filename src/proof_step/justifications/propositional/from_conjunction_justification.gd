extends Justification
class_name FromConjunctionJustification 

var conjunction : ExprItem


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="FromConjunctionJustification",
		conjunction=parse_box.serialise(conjunction)
	}


func _init(conjunction=null):
	self.conjunction = conjunction
	emit_signal("updated")


func _is_in_conjunction(expr_item:ExprItem, conj:ExprItem):
	if expr_item.compare(conj):
		return true
	elif conj.get_type() == GlobalTypes.AND and conj.get_child_count() == 2:
		return _is_in_conjunction(expr_item, conj.get_child(0)) or _is_in_conjunction(expr_item, conj.get_child(1))
	else:
		return false


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	if conjunction == null:
		return null
	var conj_statement = Statement.new(conjunction)
	var conj_conclusion = conj_statement.get_conclusion()
	var ei_conclusion = Locator.new(expr_item).get_descendent(conj_conclusion.get_indeces())
	if ei_conclusion == null:
		return null
	if not conj_conclusion.compare_contexts(ei_conclusion):
		return null
	var matching := {}
	var conj_definitions = conj_conclusion.get_outside_definitions()
	var ei_definitions = ei_conclusion.get_outside_definitions()
	for i in len(conj_statement.get_definitions()):
		matching[ei_definitions[i]] = ExprItem.new(conj_definitions[i])
	if not _is_in_conjunction(
			ei_conclusion.get_expr_item().deep_replace_types(matching), 
			conj_conclusion.get_expr_item()):
		return null
	return [
		Requirement.new(
			conjunction
		)
	]


func set_conjunction(conjunction:ExprItem):
	self.conjunction = conjunction
	emit_signal("updated")


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	var options = []
	options.append(Justification.LabelOption.new(ConstantAutostring.new("Conjunction:")))
	var eio := Justification.ExprItemOption.new(conjunction, context)
	eio.connect("expr_item_changed", self, "set_conjunction")
	options.append(eio)
	if conjunction == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Conjunction missing!"), true))
		return options
	var conj_statement = Statement.new(conjunction)
	var conj_conclusion = conj_statement.get_conclusion()
	var ei_conclusion = Locator.new(expr_item).get_descendent(conj_conclusion.get_indeces())
	if ei_conclusion == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new(
			"Conjunction does not have the right definitions / conditions!"
		), true))
		return options
	if not conj_conclusion.compare_contexts(ei_conclusion):
		options.append(Justification.LabelOption.new(ConstantAutostring.new(
			"Conjunction does not have the right definitions / conditions!"
		), true))
		return options
	var matching := {}
	var conj_definitions = conj_conclusion.get_outside_definitions()
	var ei_definitions = ei_conclusion.get_outside_definitions()
	for i in len(conj_statement.get_definitions()):
		matching[ei_definitions[i]] = ExprItem.new(conj_definitions[i])
	if not _is_in_conjunction(
			ei_conclusion.get_expr_item().deep_replace_types(matching), 
			conj_conclusion.get_expr_item()):
		options.append(Justification.LabelOption.new(ConstantAutostring.new(
			"Conjunction does not contain the desired clause."
		), true))
	return options


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("taking one clause from the above 'and',")
