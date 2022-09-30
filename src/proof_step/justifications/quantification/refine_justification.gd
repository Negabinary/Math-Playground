extends Justification
class_name RefineJustification 

var general : ExprItem

func _init(general_form:ExprItem=null):
	self.general = general_form


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="RefineJustification",
		general=parse_box.serialise(self.general)
	}


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	if general == null:
		return null
	
	var general_statement := ForallHelper.new(general)
	var specific_statement := ForallHelper.new(expr_item)
	
	var matching = {}
	for definition in general_statement.get_definitions():
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
	emit_signal("updated")


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	var options = []
	options.append(Justification.LabelOption.new(ConstantAutostring.new("General form:")))
	var eio := Justification.ExprItemOption.new(general, context)
	eio.connect("expr_item_changed", self, "set_general")
	options.append(eio)
	
	if general == null:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Expression missing!"), true))
		return options
	
	var general_statement := ForallHelper.new(general)
	var specific_statement := ForallHelper.new(expr_item)
	
	var matching = {}
	for definition in general_statement.get_definitions():
		matching[definition] = "*"
	
	var matches:bool = general_statement.get_conclusion_with_conditions().is_superset(
		specific_statement.get_conclusion_with_conditions(), matching
	)
	
	if not matches:
		options.append(Justification.LabelOption.new(ConstantAutostring.new("Not a general form"), true))
	return options


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("by taking a specific case,")


func _get_all_types() -> Dictionary:
	return general.get_all_types()
