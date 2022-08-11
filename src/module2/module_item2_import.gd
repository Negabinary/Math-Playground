extends ModuleItem2
class_name ModuleItem2Import

var module
var name : String

func _init(context:ProofBox, name:String):
	module = Module2Loader.get_module(name)
	# Todo: switch this to .get_child_extended_with()
	proof_box = OldProofBox.new(
		context, [], [], {name:module}
	)
	self.name = name


func get_import_name() -> String:
	return module.get_name()


func get_final_proof_box() -> ProofBox:
	return module.get_proof_box()


func get_module():
	return module


func serialise():
	return {kind="import", module=name}
