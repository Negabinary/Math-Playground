extends ModuleItem2
class_name ModuleItem2Import

var from : ProofBox
var name : String

func _init(context:ProofBox, name:String):
	var from = Module2Loader.get_module(name)
	proof_box = ProofBox.new(
		[], context, null, "", [], [from]
	)
	# TODO : LOAD MODULES
	self.name = name

func get_import_name() -> String:
	return name

func serialise():
	return {kind="import", module=name}
