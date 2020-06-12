extends Node
class_name ProofEntry

var acted : bool
var proven : bool
var goal : Assumption
var assumptions : Array # <Assumption>
var declarations : Array # <ExprItemType>

# Array<Assumption>, Array<ExprItemType>
func _init(new_goal:Assumption, new_assumptions:Array, new_declarations:Array):
	goal = new_goal
	assumptions = new_assumptions
	declarations = new_declarations
	acted = false
	proven = false

func get_assumptions() -> Array:
	return assumptions

func get_declarations() -> Array:
	return declarations

func get_goal() -> Assumption:
	return goal

func is_proven() -> bool:
	return proven

func has_been_acted_on() -> bool:
	return acted
