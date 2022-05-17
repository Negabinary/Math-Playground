extends Justification
class_name WitnessJustification 


var bound : ExprItemType
var statement : ExprItem
var witness : ExprItem


func _init(context:ProofBox, bound:ExprItemType, statement:ExprItem, witness:ExprItem).(
		[
			Requirement.new(
				context,
				statement.deep_replace_types({bound:witness})
			)
		]
	):
	self.bound = bound
	self.statement = statement
	self.witness = witness


func can_justify(expr_item:ExprItem) -> bool:
	return expr_item.compare(
		ExprItem.new(GlobalTypes.EXISTS,[ExprItem.new(bound), statement])
	)


func get_justification_text():
	return "WHERE " + witness.to_string() + " IS A WITNESS FOR" 
