extends Node
class_name ModuleItem

signal request_delete
signal serial_changed

var module # : Module
var docstring := ""

func _init(module, docstring=""):
	self.module = module
	self.docstring = docstring

func get_index():
	return module.get_item_index(self)

func get_module():
	return module

func get_definition() -> ExprItemType:
	return null

func get_proof() -> ProofStep:
	return null

func get_as_assumption() -> ProofStep:
	return null

func delete() -> void:
	emit_signal("request_delete")

func get_docstring() -> String:
	return docstring

func _sc():
	emit_signal("serial_changed")
