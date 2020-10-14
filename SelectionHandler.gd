extends Node
class_name SelectionHandler

signal proof_step_changed
signal locator_changed


var module : MathModule
var proof : Proveable
var proof_step : ProofStep
var locator : Locator

func get_module() -> MathModule:
	return module


func get_proof() -> Proveable:
	return proof


func get_proof_step() -> ProofStep:
	return proof_step


func get_locator() -> Locator:
	return locator


func change_module(module:MathModule):
	self.module = module
	emit_signal("module_changed", module)
	change_proof(null)


func change_proof(proof:Proveable):
	self.proof = proof
	emit_signal("proof_changed", proof)
	if proof == null:
		change_proof(null)
	else:
		change_proof_step(proof.as_conclusion())


func change_proof_step(proof_step:ProofStep):
	self.proof_step = proof_step
	emit_signal("proof_step_changed", proof_step)
	if proof_step == null:
		change_locator(null)
	else:
		change_locator(Locator.new(proof_step.get_statement().as_expr_item()))


func change_locator(locator:Locator):
	self.locator = locator
	emit_signal("locator_changed", locator)


func change_selection(proof_step:ProofStep, locator:Locator):
	change_proof_step(proof_step)
	change_locator(locator)
