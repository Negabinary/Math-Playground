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


func serialize() -> Dictionary:
	var serial_definitions := []
	for definition in definitions:
		serial_definitions.append(definition.get_identifier())
	var serial_assumptions := []
	for assumption in assumptions:
		serial_assumptions.append(assumption.serialize())
	return {
		goal=goal.serialize(),
		definitions=serial_definitions,
		assumptions=serial_assumptions
	}


static func deserialize(script, dict:Dictionary, parse_box:ParseBox) -> Requirement:
	var definitions := []
	for definition in dict.definitions:
		definitions.append(ExprItemType.new(definition))
	var new_parse_box := ParseBox.new(parse_box, definitions)
	var assumptions := []
	for assumption in dict.assumptions:
		assumptions.append(ExprItemBuilder.deserialize(assumption, new_parse_box))
	return script.new(
		ExprItemBuilder.deserialize(dict.goal, new_parse_box),
		definitions,
		assumptions
	)
