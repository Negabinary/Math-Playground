extends Control

var item

func initialise(item:ModuleItem2Implement, selection_handler:SelectionHandler):
	self.item = item
	$"%Name".text = item.get_import_name()
	$"%Definition".type = item.get_new_name_eit()
	$"%Assumption".autostring = ExprItemAutostring.new(
		item.get_assumption(),
		item.get_next_proof_box().get_parse_box()
	)
	$"%UseButtons".init(item.get_assumption(), item.get_next_proof_box(), selection_handler)

func serialise():
	return item.serialise()

func deserialise(item, proof_box, version, selection_handler:SelectionHandler):
	initialise(
		ModuleItem2Implement.new(
			proof_box,
			item.module,
			ExprItemType.new(item.new_name)
		),
		selection_handler
	)

func take_type_census(census:TypeCensus) -> TypeCensus:
	return item.take_type_census(census)

func get_next_proof_box() -> SymmetryBox:
	return item.get_next_proof_box()
