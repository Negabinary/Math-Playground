extends HBoxContainer

var item

func initialise(item:ModuleItem2Assumption):
	$Name.text = item.get_assumption().to_string()
