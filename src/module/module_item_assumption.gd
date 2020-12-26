extends ModuleItem
class_name ModuleItemAssumption

var statement : ExprItem

func _init(module, statement:ExprItem, docstring:="").(module,docstring):
	self.statement = statement


func update_statement(new_expr_item:ExprItem) -> void:
	self.statement = new_expr_item


func get_as_assumption():
	var proof_step = ProofStep.new(
		statement,
		self
	)
	proof_step.justify_with_module_axiom(module)
	return proof_step
