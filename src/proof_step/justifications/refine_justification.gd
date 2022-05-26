extends Justification
class_name RefineJustification 

var general : ExprItem


func _init(general_form:ExprItem=null):
	self.general = general_form


func get_requirements_for(expr_item:ExprItem, context:ParseBox):
	var general_statement := Statement.new(general)
	var specific_statement := Statement.new(expr_item)
	
	var matching = {}
	for definition in Statement.new(general).get_definitions():
		matching[definition] = "*"
	
	var matches:bool = general_statement.get_conclusion_with_conditions().is_superset(
		specific_statement.get_conclusion_with_conditions(), matching
	)
	
	if not matches:
		return null
	return [
		Requirement.new(
			general
		)
	]


func set_general(ei:ExprItem):
	general = ei


func get_options_for(expr_item:ExprItem, context:ParseBox):
	var options = []
	options.append(Justification.LabelOption.new("General form:"))
	var eio := Justification.ExprItemOption.new(general, context)
	eio.connect("expr_item_changed", self, "set_general")
	options.append(eio)
	
	var general_statement := Statement.new(general)
	var specific_statement := Statement.new(expr_item)
	
	var matching = {}
	for definition in Statement.new(general).get_definitions():
		matching[definition] = "*"
	
	var matches:bool = general_statement.get_conclusion_with_conditions().is_superset(
		specific_statement.get_conclusion_with_conditions(), matching
	)
	
	if not matches:
		options.append(Justification.LabelOption.new("Not a general form", true))
	return options


func get_justification_text():
	return "IS THE GENERAL CASE OF"
