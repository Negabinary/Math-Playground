extends Node
class_name ProofEntry

var acted : bool
var proven : bool
var goal : Statement
var assumptions : Array # <Statement>
var declarations : Array # <ExprItemType>

# Array<Statement>, Array<ExprItemType>
func _init(new_goal:Statement, new_assumptions:Array, new_declarations:Array):
	goal = new_goal
	assumptions = new_assumptions
	declarations = new_declarations
	acted = false
	proven = false

func add_derived_assumption(assumption:Statement) -> void:
	assumptions.append(assumption)

func get_assumptions() -> Array:
	return assumptions

func get_declarations() -> Array:
	return declarations

func get_goal() -> Statement:
	return goal

func is_proven() -> bool:
	return proven

func has_been_acted_on() -> bool:
	return acted
