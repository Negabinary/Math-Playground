extends Object
class_name MathModule

var name : String
var requirements : Array # TODO
var definitions := {}
var assumptions := []
var theorems := []

func _init():
	pass

func add_definition(definition:ExprItemType) -> void:
	definitions[definition.to_string()] = definition

func add_assumption(assumption:Statement) -> void:
	assumptions.append(assumption)

func get_definitions() -> Dictionary:
	return definitions

func get_assumptions() -> Array:
	return assumptions

func read_file(file:File) -> void:
	for line in file.get_as_text().split("\n", false):
		if line.left(2) == "$$":
			var new_def_string = line.right(len(line) - 2)
			var type := ExprItemType.new(new_def_string)
			definitions[new_def_string] = type
		else:
			var new_expr_item = ExprItem.from_string(line)
			var new_statement = Statement.new(new_expr_item)
			assumptions.append(new_statement)
