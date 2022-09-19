extends Justification
class_name WitnessJustification 

var witness : ExprItem


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="WitnessJustification",
		witness=parse_box.serialise(witness)
	}


func _init(witness:ExprItem=null):
	self.witness = witness


func set_witness(w:ExprItem):
	witness = w
	emit_signal("updated")


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	if witness == null:
		return null
	if expr_item.get_type() != GlobalTypes.EXISTS or expr_item.get_child_count() != 2:
		return null
	var type = expr_item.get_child(0).get_type()
	var matching = {type:witness}
	return [
		Requirement.new(
			expr_item.get_child(1).deep_replace_types(matching)
		)
	]


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	if expr_item.get_type() != GlobalTypes.EXISTS or expr_item.get_child_count() != 2:
		return [Justification.LabelOption.new(ConstantAutostring.new("Witness can only prove existentials!"), true)]
	var options = []
	options.append(Justification.LabelOption.new(ConstantAutostring.new("Witness:")))
	var eio = Justification.ExprItemOption.new(witness, context)
	eio.connect("expr_item_changed", self, "set_witness")
	options.append(eio)
	if witness == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Witness Missing"), true))
	return options


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	if witness:
		return ConcatAutostring.new(["using ", ExprItemAutostring.new(witness, parse_box), " as a witness,"])
	else:
		return ConstantAutostring.new("using a witness,")
