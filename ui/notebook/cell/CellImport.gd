extends HBoxContainer

var item

func initialise(item:ModuleItem2Import):
	$Name.text = item.get_import_name()
