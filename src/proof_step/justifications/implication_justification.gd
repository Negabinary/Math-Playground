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
	
	var conclusion := statement.get_conclusion().get_expr_item()
	
	var box_definitions := []
	var statement_definitions = statement.get_definitions()
	for i in statement_definitions.size():
		if not (i in keep_definition_ids):
			box_definitions.append(statement_definitions[i])
	
	var proof_box = ProofBox.new(box_definitions)
	
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
		else:
			conclusion = ExprItem.new(GlobalTypes.IMPLIES, [statement_conditions[i].get_expr_item(), conclusion])
	
	for i in statement_definitions.size():
		if i in keep_definition_ids:
			conclusion = ExprItem.new(GlobalTypes.FORALL, [ExprItem.new(statement_definitions[i]), conclusion])
	
	requirements = [
		PROOF_STEP.new(
			conclusion,
			proof_box
		)
	]


func _verify_expr_item(expr_item:ExprItem):
	return statement.compare_expr_item(expr_item)


func get_justification_text():
	return "THUS"
