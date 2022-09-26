extends HBoxContainer

var item
var read_only := true

func initialise(item:ModuleItem2Definition):
	show()
	self.item = item
	$Name.type = item.get_definition()
	if read_only:
		$Name.editable = false
		$Name.context_menu_enabled = false
		$Name.selecting_enabled = false

func serialise():
	return item.serialise()

func deserialise(item, proof_box, version, selection_handler:SelectionHandler):
	initialise(ModuleItem2Definition.new(
		proof_box, 
		ExprItemType.new(item.type)
	))

func take_type_census(census:TypeCensus) -> TypeCensus:
	return item.take_type_census(census)

func get_next_proof_box() -> SymmetryBox:
	return item.get_next_proof_box()
