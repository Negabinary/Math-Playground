extends Autostring
class_name ExprItemAutostring

signal deleted

var root : ContextLocator
var listeners := []

func _init(expr_item:ExprItem, context:AbstractParseBox):
	root = ContextLocator.new(Locator.new(expr_item), context)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for listener in listeners:
			root.get_context().remove_listener(listener)


func get_string() -> String:
	_clear_listeners()
	return _printout(root)


func _clear_listeners() -> void:
	for listener in listeners:
		listener.disconnect("updated", self,"_on_renamed")
		listener.disconnect("deleted", self,"_on_deleted")
	listeners.clear()


func _add_listener(listener:IdentifierListener) -> void:
	listeners.append(listener)
	listener.connect("updated", self,"_on_renamed")
	listener.connect("deleted", self,"_on_deleted")


func _printout(locator:ContextLocator) -> String:
	var type = locator.get_type()
	var children = locator.get_children()
	if children.size() == 0:
		var listener := locator.get_type_listener()
		_add_listener(listener)
		return listener.get_full_string()
	elif type == GlobalTypes.IMPLIES and children.size() == 2:
		return (
			"if " 
			+ _printout(children[0]) 
			+ " then " 
			+ _printout(children[1])
		)
	elif type == GlobalTypes.FORALL and children.size() == 2:
		return (
			"forall " 
			+ children[0].get_type().get_identifier()
			+ ". " 
			+ _printout(children[1])
		)
	elif type == GlobalTypes.EXISTS and children.size() == 2:
		return (
			"exists " 
			+ children[0].get_type().get_identifier()
			+ ". " 
			+ _printout(children[1])
		)
	elif type == GlobalTypes.LAMBDA and children.size() == 2:
		return (
			"fun " 
			+ children[0].get_type().get_identifier()
			+ ". " 
			+ _printout(children[1])
		)
	elif type == GlobalTypes.LAMBDA and children.size() > 2:
		var children_string:String = (
			"(fun " 
			+ children[0].get_type().get_identifier()
			+ ". " 
			+ _printout(children[1])
			+ ")("
		)
		for i in range(2, children.size() - 1):
			children_string += _printout(children[i]) + ", "
		children_string += _printout(children[-1]) + ")"
		return children_string
	elif type == GlobalTypes.AND and children.size() == 2:
		var children_string := ""
		if children[0].get_type() in [GlobalTypes.AND, GlobalTypes.OR]:
			children_string += "(" + _printout(children[0]) + ")"
		else:
			children_string += _printout(children[0])
		children_string += " and "
		if children[1].get_type() in [GlobalTypes.AND, GlobalTypes.OR]:
			children_string += "(" + _printout(children[1]) + ")"
		else:
			children_string += _printout(children[1])
		return children_string
	elif type == GlobalTypes.OR and children.size() == 2:
		var children_string := ""
		if children[0].get_type() in [GlobalTypes.OR]:
			children_string += "(" + _printout(children[0]) + ")"
		else:
			children_string += _printout(children[0])
		children_string += " or "
		if children[1].get_type() in [GlobalTypes.OR]:
			children_string += "(" + _printout(children[1]) + ")"
		else:
			children_string += _printout(children[1])
		return children_string
	elif type == GlobalTypes.EQUALITY and children.size() == 2:
		var children_string := ""
		if children[0].get_type() in [GlobalTypes.OR, GlobalTypes.AND, GlobalTypes.EQUALITY]:
			children_string += "(" + _printout(children[0]) + ")"
		else:
			children_string += _printout(children[0])
		children_string += " = "
		if children[1].get_type() in [GlobalTypes.OR, GlobalTypes.AND, GlobalTypes.EQUALITY]:
			children_string += "(" + _printout(children[1]) + ")"
		else:
			children_string += _printout(children[1])
		return children_string
	else:
		var children_string = ""
		for child in children:
			children_string += _printout(child) + ", "
		var listener := locator.get_type_listener()
		_add_listener(listener)
		return (
			listener.get_full_string()
			+ "("
			+ children_string.left(children_string.length() - 2)
			+ ")"
		)


func _on_renamed():
	emit_signal("updated")


func _on_deleted():
	emit_signal("deleted")
