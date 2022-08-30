extends HBoxContainer


func initialise(item:ExprItemType):
	show()
	$Name.text = item.to_string()
