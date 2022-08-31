class_name Justification


signal updated
signal request_replace


# GETTERS =================================================

func get_options_for_selection(expr_item:ExprItem, context:AbstractParseBox, selection:Locator):
	return get_options_for(expr_item, context)


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	return null


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	return []


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("USING SOMETHING OR OTHER")


func get_justification_description():
	return ""


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {}


# OPTIONS ===============================================


class Option:
	pass


class BooleanOption extends Option:
	signal value_changed # bool
	
	var label:Autostring
	var value:bool
	var disabled := false
	
	func _init(label:Autostring, initial_value:bool, disabled:=false):
		self.label = label
		self.value = initial_value
		self.disabled = disabled
	
	func get_label() -> Autostring:
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
	var context : AbstractParseBox
	
	func _init(expr_item:ExprItem, context:AbstractParseBox):
		self.expr_item = expr_item
		self.context = context
	
	func get_expr_item() -> ExprItem:
		return expr_item
	
	func set_expr_item(ei:ExprItem) -> void:
		self.expr_item = ei
		emit_signal("expr_item_changed", ei)
	
	func get_context() -> AbstractParseBox:
		return context


class ExprItemTypeNameOption:
	
	var expr_item_type : ExprItemType
	
	func _init(eit:ExprItemType):
		self.expr_item_type = eit
	
	func get_type() -> ExprItemType:
		return expr_item_type


class LabelOption extends Option:
	var text : Autostring
	var err : bool
	
	func _init(text:Autostring, err=false):
		self.text = text
		self.err = err
	
	func get_text():
		return text
	
	func get_is_err():
		return err


class ButtonOption extends Option:
	var text : Autostring
	var disabled : bool
	var picture : Texture
	signal pressed
	
	func _init(text:Autostring, disabled:=false, picture:Texture=null):
		self.text = text
		self.disabled = disabled
		self.picture = picture
	
	func get_text() -> Autostring:
		return text
	
	func get_is_disabled() -> bool:
		return disabled
	
	func get_image() -> Texture:
		return picture
	
	func action():
		emit_signal("pressed")


class ReplaceButtonOption extends Option:
	var text : Autostring
	var disabled : bool
	var picture : Texture
	var just : Justification
	signal pressed
	
	func _init(text:Autostring, disabled:bool, picture:Texture, replace_with:Justification):
		self.text = text
		self.disabled = disabled
		self.picture = picture
		self.just = replace_with
	
	func get_text() -> Autostring:
		return text
	
	func get_is_disabled() -> bool:
		return disabled
	
	func get_image() -> Texture:
		return picture
	
	func action():
		emit_signal("pressed")


"""
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
"""
