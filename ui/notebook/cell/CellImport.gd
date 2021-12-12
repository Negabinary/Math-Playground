extends HBoxContainer

var item

func initialise(item:ModuleItem2Import):
	self.item = item
	$Name.text = item.get_import_name()

func serialise():
	return item.serialise()

func deserialise(item, proof_box):
	self.item = ModuleItem2Import.new(
		proof_box,
		item.module
	)
