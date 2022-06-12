extends HBoxContainer

var item

func initialise(item:ModuleItem2Definition):
	show()
	self.item = item
	$Name.text = item.get_definition().to_string()

func serialise():
	return item.serialise()

func deserialise(item, proof_box, version):
	initialise(ModuleItem2Definition.new(
		proof_box, 
		ExprItemType.new(item.type)
	))
