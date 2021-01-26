extends Justification
class_name ImplicationJustification 

var context : ProofBox
var statement : Statement
var keep_condition_ids : Array
var keep_definition_ids : Array


var s : Script


func _init(context:ProofBox, statement:Statement, keep_condition_ids:=[], keep_definition_ids:=[]):
	self.context = context
	self.statement = statement
	self.keep_condition_ids = keep_condition_ids
	self.keep_definition_ids = keep_definition_ids
	_calculate_requirements()


func _calculate_requirements():
	var box_definitions := []
	var statement_definitions = statement.get_definitions()
	for i in statement_definitions.size():
		if not (i in keep_definition_ids):
			box_definitions.append(statement_definitions[i])
	
	var proof_box = ProofBox.new(box_definitions, context)
	
	var statement_conditions = statement.get_conditions()
	for i in statement_conditions.size():
		if not (i in keep_condition_ids):
			proof_box.add_assumption(
				PROOF_STEP.new(
					statement_conditions[i].get_expr_item(),
					context,
					AssumptionJustification.new(proof_box)
				)
			)
	
	var conclusion := statement.construct_without(keep_definition_ids, keep_condition_ids)
	
	requirements = [
		PROOF_STEP.new(
			conclusion,
			proof_box
		)
	]


func _verify_expr_item(expr_item:ExprItem):
	var has_undeclared_variables := false
	var all_variables := statement.get_definitions()
	var keep_variables := []
	for i in all_variables.size():
		if i in keep_definition_ids:
			keep_variables.append(all_variables[i])
	var all_conditions := statement.get_conditions()
	for i in all_conditions.size():
		if not (i in keep_condition_ids):
			for keep_variable in keep_variables:
				if keep_variable in all_conditions[i].get_expr_item().get_all_types():
					has_undeclared_variables = true
	return statement.compare_expr_item(expr_item) and not has_undeclared_variables


func get_justification_text():
	return "THUS"


func get_options() -> Array:
	var strings := []
	for definition in statement.get_definitions():
		strings.append("DEFINE " + definition.to_string())
	for condition in statement.get_conditions():
		strings.append("ASSUME " + condition.to_string())
	return strings


func get_option_type(option_idx:int) -> int:
	return OPTION_TYPES.BOOLEAN


func set_option(option_idx:int, value) -> void:
	if option_idx < statement.get_definitions().size():
		if option_idx in keep_definition_ids:
			if value:
				keep_definition_ids.remove(option_idx)
		else:
			if not value:
				keep_definition_ids.append(option_idx)
		var definition = statement.get_definitions()[option_idx]
		for i in statement.get_conditions().size():
			if (not (i in keep_condition_ids)) and definition in statement.get_conditions()[i].get_expr_item().get_all_types():
				keep_condition_ids.append(i)
	else:
		option_idx -= statement.get_definitions().size()
		if option_idx in keep_condition_ids:
			if value:
				keep_condition_ids.remove(option_idx)
		else:
			if not value:
				keep_condition_ids.append(option_idx)
	_calculate_requirements()
	emit_signal("justified")


func get_option(option_idx:int):
	if option_idx < statement.get_definitions().size():
		return not option_idx in keep_definition_ids
	else:
		option_idx -= statement.get_definitions().size()
		return not option_idx in keep_condition_ids


func get_option_disabled(option_idx:int) -> bool:
	if option_idx >= statement.get_definitions().size():
		option_idx -= statement.get_definitions().size()
		var condition = statement.get_conditions()[option_idx].get_expr_item()
		var all_types = condition.get_all_types()
		var return_value := false
		for i in keep_definition_ids:
			if statement.get_definitions()[i] in all_types:
				return_value = true
		return return_value
	else:
		return false
