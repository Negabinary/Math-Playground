extends Control

var item

func initialise(item:ModuleItem2Import, selection_handler:SelectionHandler):
	self.item = item
	$"%Name".text = item.get_import_name()
	$"%Book".module = item.get_module()
	$"%Book".selection_handler = selection_handler
	$"%NamespaceButton".pressed = item.is_using_namespace()
	$"%NamespaceButton".connect("toggled", item, "set_namespace")

func serialise():
	return item.serialise()

func deserialise(item, proof_box, version, selection_handler:SelectionHandler):
	initialise(
		ModuleItem2Import.new(
			proof_box,
			item.module,
			item.get("namespace", false)
		),
		selection_handler
	)

func take_type_census(census:TypeCensus) -> TypeCensus:
	return item.take_type_census(census)

func get_next_proof_box() -> SymmetryBox:
	return item.get_next_proof_box()
