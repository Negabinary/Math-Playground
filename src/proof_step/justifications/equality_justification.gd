extends Justification
class_name EqualityJustification


var replace : Locator
var with : ExprItem
var conditions : Array #<ExprItem>
var forwards : bool


func _init(context:ProofBox, replace:Locator, with:ExprItem, conditions:=[], forwards:=true): #<ExprItem>
	self.replace = replace
	self.with = with
	self.conditions = conditions
	self.forwards = forwards
	
	var equality_expr_item : ExprItem
	if forwards:
		equality_expr_item = ExprItem.new(GlobalTypes.EQUALITY, [replace.get_expr_item(), with])
	else:
		equality_expr_item = ExprItem.new(GlobalTypes.EQUALITY, [with, replace.get_expr_item()])
	for i in conditions.size():
		var condition : ExprItem = conditions[-i-1]
		equality_expr_item = ExprItem.new(GlobalTypes.IMPLIES, [condition, equality_expr_item])
	
	requirements = [PROOF_STEP.new(equality_expr_item, context)]
	for condition in conditions:
		requirements.append(PROOF_STEP.new(condition, context))
	var with_replacement := replace.get_root().replace_at(replace.get_indeces(), with)
	requirements.append(PROOF_STEP.new(with_replacement, context))


func _verify_expr_item(expr_item:ExprItem) -> bool:
	return expr_item.compare(replace.get_root())


func get_equality_proof_step():
	return requirements[0]


func get_justification_text():
	return "USING " + requirements[0].get_statement().to_string()	
