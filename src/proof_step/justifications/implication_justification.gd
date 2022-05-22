extends Justification
class_name ImplicationJustification 


var keep_condition_ids : Array
var keep_definition_ids : Array


func _init(keep_definition_ids=[], keep_condition_ids=[]):
	self.keep_condition_ids = keep_condition_ids
	self.keep_definition_ids = keep_definition_ids


func get_requirements_for(expr_item:ExprItem, context:ParseBox):
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
	return [
		Requirement.new(
			conclusion,
			box_definitions,
			box_assumptions
		)
	]


func set_keep_condition(value:bool, idx:int):
	if value and not (idx in keep_condition_ids):
		keep_condition_ids.append(idx)
	elif (not value) and (idx in keep_condition_ids):
		keep_condition_ids.erase(idx)


func set_keep_definition(value:bool, idx:int, reliant_conditions:Array):
	if value and not (idx in keep_definition_ids):
		keep_definition_ids.append(idx)
		for r in reliant_conditions:
			if not (r in keep_condition_ids):
				keep_condition_ids.append(r)
	elif (not value) and (idx in keep_definition_ids):
		keep_definition_ids.erase(idx)


func get_options_for(expr_item:ExprItem, context:ParseBox):
	var options := []
	var statement := Statement.new(expr_item)
	for i in statement.get_definitions().size():
		var bo := Justification.BooleanOption.new(
			"DEFINE " + statement.get_definitions()[i].to_string(), 
			i in keep_definition_ids
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
				if statement.get_definitions()[j] in statement.get_conditions()[i].get_all_types():
					disabled = true
		var co := Justification.BooleanOption.new(
			"ASSUME " + statement.get_conditions()[i].to_string(), 
			i in keep_condition_ids,
			disabled
		)
		co.connect("value_changed", self, "set_keep_condition", [i])
		options.append(co)
	return options


func get_justification_text():
	return "USING SOMETHING OR OTHER"
