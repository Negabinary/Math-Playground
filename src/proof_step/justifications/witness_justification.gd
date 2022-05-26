extends Justification
class_name WitnessJustification 


var witness : ExprItem


func _init(witness:=null):
	self.witness = witness


func set_witness(w:ExprItem):
	witness = w


func get_requirements_for(expr_item:ExprItem, context:ParseBox):
	if witness == null:
		return null
	if expr_item.get_type() != GlobalTypes.EXISTS or expr_item.get_child_count() != 2:
		return null
	var type = expr_item.get_child(0).get_type()
	var matching = {type:witness}
	return [
		Statement.new(
			expr_item.get_child(1).deep_replace_types(matching)
		)
	]


func get_options_for(expr_item:ExprItem, context:ParseBox):
	if expr_item.get_type() != GlobalTypes.EXISTS or expr_item.get_child_count() != 2:
		return [Justification.LabelOption.new("Witness can only prove existentials!", true)]
	var options = []
	options.append(Justification.LabelOption.new("Witness:"))
	var eio = Justification.ExprItemOption.new(witness, context)
	eio.connect("expr_item_changed", self, "set_witness")
	options.append(eio)
	if witness == null:
		options.append(Justification.LabelOption.new("Witness Missing", true))
	return []


func get_justification_text():
	return "WHERE " + witness.to_string() + " IS A WITNESS FOR" 
