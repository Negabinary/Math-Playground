extends Node
class_name SelectionHandler

signal proof_changed
signal module_changed
signal proof_step_changed
signal locator_changed


var module : MathModule
var proof : ProofStep
var proof_step : ProofStep
var locator : Locator

func get_module() -> MathModule:
	return module


func get_proof() -> ProofStep:
	return proof


func get_proof_step() -> ProofStep:
	return proof_step


func get_locator() -> Locator:
	return locator


func change_module(module:MathModule):
	self.module = module
	emit_signal("module_changed", module)


func change_proof(proof:ProofStep):
	self.proof = proof
	emit_signal("proof_changed", proof)


func change_proof_step(proof_step:ProofStep):
	self.proof_step = proof_step
	emit_signal("proof_step_changed", proof_step)


func change_locator(locator:Locator):
	self.locator = locator
	emit_signal("locator_changed", locator)


func change_selection(proof_step:ProofStep, locator:Locator):
	change_proof_step(proof_step)
	change_locator(locator)


func load_proof(proveable:ProofStep):
	change_module(proveable.get_justification().get_module())
	var proof = module.get_proof(proveable)
	change_proof(proof)
	change_proof_step(proof)
	change_locator(null)
