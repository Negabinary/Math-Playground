extends ItemList


var definitions := []

signal expr_item_dropped_on_definition


func can_drop_data(position, data):
	print(data)
	if get_item_at_position(position) != -1 and data is UniversalLocator:
		return true
	else:
		return false


func drop_data(position, data):
	var item := get_item_at_position(position)
	if item != -1 and data is UniversalLocator:
		print("EY")
		emit_signal("expr_item_dropped_on_definition", definitions[item], data)


func update_definitions(new_definitions:Array): # Array<ExprItemType>
	definitions = new_definitions
	for definition in definitions:
		add_item(definition.to_string())
		print(definition.to_string())
