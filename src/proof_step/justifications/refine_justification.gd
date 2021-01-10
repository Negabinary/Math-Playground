extends Justification
class_name RefineJustification 

var general : ExprItem
var matching : Dictionary

func _init(context:ProofBox, general:ExprItem, matching:Dictionary):
	self.general = general
	self.matching = matching
	requirements = [PROOF_STEP.new(general, context)]


func _verify_expr_item(expr_item:ExprItem) -> bool:
	return true
	print("===")
	print(expr_item)
	print(Statement.new(general).deep_replace_types(matching).as_expr_item())
	print("===")
	return expr_item.compare(Statement.new(general).deep_replace_types(matching).as_expr_item())


func get_generalized():
	return requirements[0]



"""
func _init(
		context:ProofStep,
		generalised,
		_matching:Dictionary):
	if generalised is String:
		var new_type = ExprItemType.new(generalised)
		var new_ei = ExprItem.new(
			GlobalTypes.FORALL, [
				ExprItem.new(new_type),
				context.get_statement().as_expr_item()
			]
		)
		requirements = [context.get_script().new(
			new_ei,
			context.get_proof_box(),
			MissingJustification.new()
		)]
	else:
		requirements = [generalised]


func get_justification_text():
	return "IS THE GENERAL CASE OF"
"""
