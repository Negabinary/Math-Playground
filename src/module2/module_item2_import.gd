extends ModuleItem2
class_name ModuleItem2Import

var from : ProofBox

func _init(context:ProofBox, from:ProofBox):
	proof_box = ProofBox.new(
		[], context, null, "", [], [from]
	)
	self.from = from

func get_import_name() -> String:
	return "CANT IMPORT YET"
