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


func compare(other:Requirement):
	if not goal.compare(other.goal):
		return false
	var d1_copy := definitions.duplicate()
	var d2_copy := other.definitions.duplicate()
	for x in d1_copy:
		if not x in d2_copy:
			return false
		d2_copy.erase(x)
	if d2_copy.size() > 0:
		return false
	var a1_copy := assumptions.duplicate()
	var a2_copy := other.assumptions.duplicate()
	for x in a1_copy:
		var found := false
		for y in a2_copy:
			if x.compare(y):
				a2_copy.erase(y)
				found = true
				break
		if not found:
			return false
	if a2_copy.size() > 0:
		return false
	return true
