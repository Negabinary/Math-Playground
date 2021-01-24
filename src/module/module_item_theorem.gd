extends ModuleItem
class_name ModuleItemTheorem

var statement : ExprItem
var previously_proven := false
var proof : ProofStep
var is_axiom := false

func _init(module, statement:ExprItem, is_axiom:bool, previously_proven := false, docstring:="").(module,docstring):
	self.is_axiom = is_axiom
	update_statement(statement)


func update_statement(new_expr_item:ExprItem) -> void:
	self.statement = new_expr_item
	if statement != null:
		self.proof = ProofStep.new(statement, module.get_proof_box())
	_sc()


func get_statement() -> ExprItem:
	return statement


func get_proof() -> ProofStep:
	return proof


func get_is_axiom() -> bool:
	return is_axiom


func set_is_axiom(is_axiom:bool) -> void:
	self.is_axiom = is_axiom
	_sc()


func get_as_assumption():
	if statement != null:
		var proof_step = ProofStep.new(
			statement,
			module.get_proof_box(),
			AssumptionJustification.new(module.get_proof_box())
		)
		return proof_step


func has_as_assumption() -> bool:
	return statement != null
