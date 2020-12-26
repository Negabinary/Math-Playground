extends ModuleItem
class_name ModuleItemTheorem

var statement : ExprItem
var previously_proven := false

func _init(module, statement:ExprItem, previously_proven := false, docstring:="").(module,docstring):
	update_statement(statement)


func update_statement(new_expr_item:ExprItem) -> void:
	self.statement = new_expr_item


func get_proof() -> ProofStep:
	assert (false) # NOT SURE WHAT TO DO HERE...
	return null


func get_as_assumption():
	var proof_step = ProofStep.new(
		statement,
		module
	)
	proof_step.justify_with_module_axiom(module)
	return proof_step
