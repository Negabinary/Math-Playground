extends Justification
class_name FromConjunctionJustification 

var conjunction : ExprItem


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="FromConjunctionJustification"
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
	if not _is_in_conjunction(expr_item, conjunction):
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
	if not _is_in_conjunction(expr_item, conjunction):
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Conjunction does not contain the desired clause."), true))
	return options


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("taking one clause of the 'and',")
