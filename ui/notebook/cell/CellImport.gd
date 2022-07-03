extends HBoxContainer

var item

func initialise(item:ModuleItem2Import, selection_handler:SelectionHandler):
	self.item = item
	$Name.text = item.get_import_name()
	$BookButton/Book.module = item.get_module()
	$BookButton/Book.selection_handler = selection_handler

func serialise():
	return item.serialise()

func deserialise(item, proof_box, version, selection_handler:SelectionHandler):
	initialise(
		ModuleItem2Import.new(
			proof_box,
			item.module
		),
		selection_handler
	)
