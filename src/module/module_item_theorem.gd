extends ModuleItem
class_name ModuleItemTheorem

var statement : ExprItem
var previously_proven := false
var proof : ProofStep

func _init(module, statement:ExprItem, previously_proven := false, docstring:="").(module,docstring):
	update_statement(statement)


func update_statement(new_expr_item:ExprItem) -> void:
	self.statement = new_expr_item
	if statement != null:
		self.proof = ProofStep.new(statement, module)
	_sc()


func get_statement() -> ExprItem:
	return statement


func get_proof() -> ProofStep:
	return proof


func get_as_assumption():
	if statement != null:
		var proof_step = ProofStep.new(
			statement,
			module
		)
		proof_step.justify_with_module_axiom(module)
		return proof_step
