extends HBoxContainer

var option : Justification.ExprItemOption
var context : ParseBox

func init(option:Justification.ExprItemOption):
	self.option = option
	$Label.text = option.get_expr_item().to_string()
	$Button.connect("pressed", $ConfirmationDialog, "popup_centered")
	$ConfirmationDialog/VBoxContainer/TextEdit.connect("text_changed", self, "_validate")
	_validate()


func _validate():
	var string_to_parse = Parser2.new()
