extends HBoxContainer

var item

func initialise(item:ModuleItem2Definition):
	show()
	$Name.text = item.get_definition().to_string()
