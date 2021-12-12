extends HBoxContainer

var item

func initialise(item:ModuleItem2Assumption):
	self.item = item
	$Name.text = item.get_assumption().to_string()

func serialise():
	return item.serialise()

func deserialise(item, proof_box):
	self.item = ModuleItem2Assumption.new(
		proof_box, 
		ExprItemBuilder.from_string(item.expr, proof_box)
	)
