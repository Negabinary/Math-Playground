extends ModuleItem2
class_name ModuleItem2Import

var module
var name : String
var namespace := false

func _init(context:SymmetryBox, name:String, namespace:=false):
	module = Module2Loader.get_module(name)
	# Todo: switch this to .get_child_extended_with()
	proof_box = SymmetryBox.new(
		ImportJustificationBox.new(
			context.get_justification_box(),
			name,
			module.get_final_proof_box().get_justification_box()
		),
		ImportParseBox.new(
			context.get_parse_box(),
			name,
			module.get_final_proof_box().get_parse_box(),
			namespace
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
	return {kind="import", module=name, namespace=namespace}
