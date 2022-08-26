class_name ContextLocator

var locator : Locator
var parse_box : ParseBox


func _init(locator, parse_box):
	self.locator = locator
	self.parse_box = parse_box

func get_locator() -> Locator:
	return locator

func get_type() -> ExprItemType:
	return get_locator().get_type()

func get_context() -> ParseBox:
	return parse_box

func get_type_name() -> String:
	return parse_box.get_name_for(locator.get_type())

func get_expr_item() -> ExprItem:
	return locator.get_expr_item()

func get_child_count() -> int:
	return locator.get_child_count()

func get_child(idx:int) -> ContextLocator:
	var loc_child := locator.get_child(idx)
	var pb_child := parse_box
	if locator.get_type().is_binder() and idx < 2:
		pb_child = ParseBox.new(pb_child, [locator.get_child(0).get_type()])
	return get_script().new(loc_child, pb_child)

func get_parent_type() -> ExprItemType:
	return locator.get_parent_type()

func listen_to_type(listener, on_rename:="", on_delete:="") -> void:
	parse_box.listen_to_type(get_type(), listener, on_rename, on_delete)


func is_listening_to_type(listener, on_rename:="", on_delete:="") -> bool:
	return parse_box.is_listening_to_type(get_type(), listener, on_rename, on_delete)


func unlisten_to_type(listener, on_rename:="", on_delete:="") -> void:
	parse_box.unlisten_to_type(get_type(), listener, on_rename, on_delete)

