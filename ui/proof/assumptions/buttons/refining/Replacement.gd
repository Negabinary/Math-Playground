extends Control

var context : AbstractParseBox
var type : ExprItemType
var is_valid = true
var expr_item = true


func init(context:AbstractParseBox, type:ExprItemType):
	self.context = context
	self.type = type
	$"%Label".text = type.get_identifier() + " = "
	$"%ExprItemEntry".text = type.get_identifier()
	_on_text_changed()
	$"%ExprItemEntry".connect("text_changed", self, "_on_text_changed")
	$"%Indicator".connect("pressed", self, "_on_indicator_pressed")


func _on_indicator_pressed():
	$"%Explanation".visible = $"%Indicator".pressed


func _on_text_changed():
	var string_to_parse = $"%ExprItemEntry".text
	var parser = ExprItemParser2.new(string_to_parse, context)
	if parser.error:
		if is_valid:
			is_valid = false
			expr_item = null
			$"%Indicator".theme_type_variation = "OptionWarn"
			emit_signal("updated")
		$"%Explanation".text = str(parser.error_dict)
	else:
		is_valid = true
		expr_item = parser.result
		$"%Indicator".theme_type_variation = "OptionTicked"
		$"%Explanation".text = ""
		$"%Indicator".pressed = false
		emit_signal("updated")


signal updated


func is_valid() -> bool:
	return is_valid


func get_expr_item() -> ExprItem:
	return expr_item
