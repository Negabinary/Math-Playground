extends Object
class_name Requirement


var goal : ExprItem
var goal_uid : String
var definitions : Array # <ExprItemType>
var assumptions : Array # <ExprItem>


func _init(goal:ExprItem, definitions=[], assumptions=[]):
	self.goal = goal
	self.goal_uid = goal.get_unique_name()
	self.definitions = definitions
	self.assumptions = assumptions


func get_goal() -> ExprItem:
	return goal


func get_definitions() -> Array:
	return definitions


func get_assumptions() -> Array:
	return assumptions
