extends VBoxContainer

var item
var selection_handler
var autostring : Autostring

func initialise(item:ModuleItem2Assumption, selection_handler:SelectionHandler):
	self.item = item
	self.selection_handler = selection_handler
	$"%Name".autostring = ExprItemAutostring.new(
		item.get_assumption(),
		item.get_next_proof_box().get_parse_box()
	)
	$"%UseButtons".init(item.get_assumption(), item.get_next_proof_box(), selection_handler)

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

func take_type_census(census:TypeCensus) -> TypeCensus:
	return item.take_type_census(census)
