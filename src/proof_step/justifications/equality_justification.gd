extends Justification
class_name EqualityJustification


var replace : Locator
var with : ExprItem
var conditions : Array #<ExprItem>
var forwards : bool


static func _get_requirements(context:ProofBox, replace:Locator, with:ExprItem, conditions:=[], forwards:=true):
	var equality_expr_item : ExprItem
	if forwards:
		equality_expr_item = ExprItem.new(GlobalTypes.EQUALITY, [replace.get_expr_item(), with])
	else:
		equality_expr_item = ExprItem.new(GlobalTypes.EQUALITY, [with, replace.get_expr_item()])
	for i in conditions.size():
		var condition : ExprItem = conditions[-i-1]
		equality_expr_item = ExprItem.new(GlobalTypes.IMPLIES, [condition, equality_expr_item])
	var reqs := [Requirement.new(context, equality_expr_item)]
	for condition in conditions:
		reqs.append(Requirement.new(context, condition))
	var with_replacement := replace.get_root().replace_at(replace.get_indeces(), with)
	reqs.append(Requirement.new(context, with_replacement))
	return reqs


func _init(context:ProofBox, replace:Locator, with:ExprItem, conditions:=[], forwards:=true).(
		_get_requirements(context, replace, with, conditions, forwards)
	): #<ExprItem>
	self.replace = replace
	self.with = with
	self.conditions = conditions
	self.forwards = forwards


func can_justify(expr_item:ExprItem) -> bool:
	return expr_item.compare(replace.get_root())


func get_equality_requirement():
	return requirements[0]


func get_justification_text():
	return "USING " + requirements[0].get_statement().to_string()	
