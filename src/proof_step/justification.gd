class_name Justification


signal updated
signal request_replace


# GETTERS =================================================

func get_options_for_selection(expr_item:ExprItem, context:ParseBox, selection:Locator):
	return get_options_for(expr_item, context)


func get_requirements_for(expr_item:ExprItem, context:ParseBox):
	return null


func get_options_for(expr_item:ExprItem, context:ParseBox):
	return []


func get_justification_text():
	return "USING SOMETHING OR OTHER"


func get_justification_description():
	return ""


# OPTIONS ===============================================


class Option:
	pass


class BooleanOption extends Option:
	signal value_changed # bool
	
	var label:String
	var value:bool
	var disabled = false
	
	func _init(label:String, initial_value:bool, disabled:=false):
		self.label = label
		self.value = initial_value
	
	func get_label() -> String:
		return label
	
	func get_disabled() -> bool:
		return disabled
	
	func get_value() -> bool:
		return value
	
	func set_value(x:bool):
		value = x
		emit_signal("value_changed", x)


class ExprItemOption extends Option:
	signal expr_item_changed
	
	var expr_item : ExprItem
	var context : ParseBox
	
	func _init(expr_item:ExprItem, context:ParseBox):
		self.expr_item = expr_item
		self.context = context
	
	func get_expr_item() -> ExprItem:
		return expr_item
	
	func set_expr_item(ei:ExprItem) -> void:
		self.expr_item = ei
		emit_signal("expr_item_changed")
	
	func get_context() -> ParseBox:
		return context


class ExprItemTypeNameOption:
	
	var expr_item_type : ExprItemType
	
	func _init(eit:ExprItemType):
		self.expr_item_type = eit
	
	func get_type() -> ExprItemType:
		return expr_item_type


class LabelOption extends Option:
	var text : String
	var err : bool
	
	func _init(text:String, err=false):
		self.text = text
		self.err = err
	
	func get_text():
		return text
	
	func get_is_err():
		return err


class ButtonOption extends Option:
	var text : String
	var disabled : bool
	signal pressed
	
	func _init(text, disabled:=false):
		self.text = text
		self.disabled = disabled
	
	func get_text():
		return text
	
	func get_is_disabled():
		return disabled
	
	func action():
		emit_signal("pressed")


class LocatorOption:
	signal location_updated
	var expr_item : ExprItem
	var location : Locator
	
	func _init(expr_item:ExprItem, locator:Locator):
		self.expr_item = expr_item
		self.location = location
		
	func get_expr_item():
		return expr_item
	
	func get_locator():
		return location
	
	func set_locator(locator:Locator):
		location = locator
		emit_signal("updated")
