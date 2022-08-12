extends ModuleItem2
class_name ModuleItem2Import

var module
var name : String

func _init(context:SymmetryBox, name:String):
	module = Module2Loader.get_module(name)
	# Todo: switch this to .get_child_extended_with()
	proof_box = SymmetryBox.new(
		ImportJustificationBox.new(
			context.get_justification_box(),
			name,
			module.get_final_proof_box().get_justification_box(),
			false # TODO: change to 'true'
		)
	)
	self.name = name


func get_import_name() -> String:
	return module.get_name()


func get_final_proof_box() -> SymmetryBox:
	return module.get_proof_box()


func get_module():
	return module


func serialise():
	return {kind="import", module=name}
