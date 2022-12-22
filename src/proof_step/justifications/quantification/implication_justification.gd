extends Justification
class_name ImplicationJustification 


var keep_condition_ids : Array
var keep_definition_ids : Array
var definition_identifiers #Array # <ExprItemType>


func _init(keep_definition_ids=[], keep_condition_ids=[],definition_identifier_names=null):
	self.keep_condition_ids = keep_condition_ids
	self.keep_definition_ids = keep_definition_ids
	if definition_identifier_names:
		definition_identifiers = []
		for i in definition_identifier_names:
			definition_identifiers.append(ExprItemType.new(i))


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	if definition_identifiers:
		var definition_identifier_names := []
		for di in definition_identifiers:
			definition_identifier_names.append(di.get_identifier())
		return {
			justification_version=2,
			justification_type="ImplicationJustification",
			keep_condition_ids=keep_condition_ids,
			keep_definition_ids=keep_definition_ids,
			definition_identifier_names=definition_identifier_names
		}
	else:
		return {
			justification_version=1,
			justification_type="ImplicationJustification",
			keep_condition_ids=keep_condition_ids,
			keep_definition_ids=keep_definition_ids
		}


func get_requirements_for(expr_item:ExprItem):
	var statement := Statement.new(expr_item)
	var box_definitions := []
	var statement_definitions = statement.get_definitions()
	for i in statement_definitions.size():
		if not (i in keep_definition_ids):
			box_definitions.append(statement_definitions[i])
	var box_assumptions := []
	var statement_conditions = statement.get_conditions()
	for i in statement_conditions.size():
		if not (i in keep_condition_ids):
			box_assumptions.append(statement_conditions[i].get_expr_item())
	var conclusion := statement.construct_without(keep_definition_ids, keep_condition_ids)
	if definition_identifiers == null:
		definition_identifiers = []
		for box_definition in box_definitions:
			definition_identifiers.append(ExprItemType.new(box_definition.get_identifier()))
	var replacements := {}
	for d in len(box_definitions):
		replacements[box_definitions[d]] = ExprItem.new(definition_identifiers[d])
	var new_conditions := []
	for ba in box_assumptions:
		new_conditions.append(ba.deep_replace_types(replacements))
	var new_conclusion := conclusion.deep_replace_types(replacements)
	return [
		Requirement.new(
			new_conclusion,
			definition_identifiers,
			new_conditions
		)
	]


func set_keep_condition(not_value:bool, idx:int):
	if (not not_value) and not (idx in keep_condition_ids):
		keep_condition_ids.append(idx)
	elif (not_value) and (idx in keep_condition_ids):
		keep_condition_ids.erase(idx)
	emit_signal("updated")


func set_keep_definition(not_value:bool, idx:int, reliant_conditions:Array):
	if (not not_value) and not (idx in keep_definition_ids):
		keep_definition_ids.append(idx)
		for r in reliant_conditions:
			if not (r in keep_condition_ids):
				keep_condition_ids.append(r)
	elif (not_value) and (idx in keep_definition_ids):
		keep_definition_ids.erase(idx)
	emit_signal("updated")


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	var options := []
	var statement := Statement.new(expr_item)
	for i in statement.get_definitions().size():
		var bo := Justification.BooleanOption.new(
			ConcatAutostring.new(["DEFINE ", statement.get_definitions()[i]]), 
			not i in keep_definition_ids
		)
		var rc := []
		for j in statement.get_conditions().size():
			if statement.get_definitions()[i] in statement.get_conditions()[j].get_all_types():
				rc.append(j)
		bo.connect("value_changed", self, "set_keep_definition", [i, rc])
		options.append(bo)
	for i in statement.get_conditions().size():
		var disabled := false
		for j in statement.get_definitions().size():
			if j in keep_definition_ids:
				if statement.get_definitions()[j] in statement.get_conditions()[i].get_all_types().keys():
					disabled = true
		var co := Justification.BooleanOption.new(
			ConcatAutostring.new(["ASSUME ", ExprItemAutostring.new(statement.get_conditions()[i].get_expr_item(), statement.get_inner_parse_box(context))]),
			not i in keep_condition_ids,
			disabled
		)
		co.connect("value_changed", self, "set_keep_condition", [i])
		options.append(co)
	return options


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("thus,")


func _get_all_types() -> Dictionary:
	return {}
