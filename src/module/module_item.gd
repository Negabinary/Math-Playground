extends Node
class_name ModuleItem

var module # : Module
var docstring := ""

func _init(module, docstring=""):
	self.module = module
	self.docstring = docstring

func get_definition() -> ExprItemType:
	return null

func get_proof() -> ProofStep:
	return null

func get_as_assumption() -> ProofStep:
	return null
