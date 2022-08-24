extends VBoxContainer

var item
var selection_handler

func initialise(item:ModuleItem2Assumption, selection_handler:SelectionHandler):
	self.item = item
	self.selection_handler = selection_handler
	$HBoxContainer/Name.text = item.get_next_proof_box().get_parse_box().printout(item.get_assumption())
	$HBoxContainer2/Star.init(item.get_assumption(), item.get_next_proof_box(), selection_handler)
	$HBoxContainer2/Use.init(item.get_assumption(), item.get_next_proof_box(), selection_handler)
	$HBoxContainer2/Instantiate.init(item.get_assumption(), item.get_next_proof_box(), selection_handler)
	$HBoxContainer2/EqLeft.init(item.get_assumption(), item.get_next_proof_box(), selection_handler, true)
	$HBoxContainer2/EqRight.init(item.get_assumption(), item.get_next_proof_box(), selection_handler)

func serialise():
	return item.serialise()

func deserialise(item, proof_box, version, selection_handler:SelectionHandler):
	initialise(
		ModuleItem2Assumption.new(
			proof_box, 
			ExprItemBuilder.deserialize(item.expr, proof_box.get_parse_box())
		),
		selection_handler
	)
