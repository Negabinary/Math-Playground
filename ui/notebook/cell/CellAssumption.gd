extends VBoxContainer

var item
var selection_handler
var autostring : Autostring

func initialise(item:ModuleItem2Assumption, selection_handler:SelectionHandler):
	self.item = item
	self.selection_handler = selection_handler
	autostring = ExprItemAutostring.new(
		item.get_assumption(),
		item.get_next_proof_box().get_parse_box()
	)
	autostring.connect("updated", self, "_update_text")
	_update_text()
	$"%UseButtons".init(item.get_assumption(), item.get_next_proof_box(), selection_handler)

func _update_text():
	$"%Name".text = autostring.get_string()

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
