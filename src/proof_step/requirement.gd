class_name Requirement


var goal : ExprItem
var definitions : Array # <ExprItemType>
var assumptions : Array # <ExprItem>


func _init(goal:ExprItem, definitions=[], assumptions=[]):
	self.goal = goal
	self.definitions = definitions
	self.assumptions = []
	for ass in assumptions:
		_add_de_anded_assumption(ass)


func _add_de_anded_assumption(ass):
	if ass.get_type() == GlobalTypes.AND and ass.get_child_count() == 2:
		_add_de_anded_assumption(ass.get_child(0))
		_add_de_anded_assumption(ass.get_child(1))
	else:
		assumptions.append(ass)


func get_goal() -> ExprItem:
	return goal


func get_definitions() -> Array:
	return definitions


func get_assumptions() -> Array:
	return assumptions


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	var serial_definitions := []
	for definition in definitions:
		serial_definitions.append(definition.get_identifier())
	var serial_assumptions := []
	for assumption in assumptions:
		serial_assumptions.append(parse_box.serialise(assumption))
	return {
		goal=parse_box.serialise(goal),
		definitions=serial_definitions,
		assumptions=serial_assumptions
	}


static func deserialize(script, dict:Dictionary, context) -> Requirement:  # : SymmetryBox
	var definitions := []
	for definition in dict.definitions:
		definitions.append(ExprItemType.new(definition))
	var new_context = context.get_child_extended_with(definitions)
	var assumptions := []
	for assumption in dict.assumptions:
		assumptions.append(ExprItemBuilder.deserialize(assumption, new_context.get_parse_box()))
	return script.new(
		ExprItemBuilder.deserialize(dict.goal, new_context.get_parse_box()),
		definitions,
		assumptions
	)
