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


func get_justification_text():
	return "IS THE GENERAL CASE OF (" + str(matching) + ")"
