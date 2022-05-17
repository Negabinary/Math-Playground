extends Justification
class_name RefineJustification 

var general : ExprItem
var matching : Dictionary

func _init(context:ProofBox, general:ExprItem, matching:Dictionary).(
		[Requirement.new(context, general)]
	):
	self.general = general
	self.matching = matching


func can_justify(expr_item:ExprItem) -> bool:
	return true
	print("===")
	print(expr_item)
	print(general.deep_replace_types(matching))
	print("===")
	return expr_item.compare(general.deep_replace_types(matching))


func get_generalized():
	return requirements[0]


func get_justification_text():
	return "IS THE GENERAL CASE OF (" + str(matching) + ")"
