extends Node
class_name SelectionHandler

signal proof_step_changed
signal locator_changed

var proof_step : ProofStep
var locator : Locator


func get_proof_step() -> ProofStep:
	return proof_step


func get_locator() -> Locator:
	return locator


func change_proof_step(proof_step:ProofStep):
	self.proof_step = proof_step
	emit_signal("proof_step_changed", proof_step)


func change_locator(locator:Locator):
	self.locator = locator
	emit_signal("locator_changed", locator)


func change_selection(proof_step:ProofStep, locator:Locator):
	change_proof_step(proof_step)
	change_locator(locator)
