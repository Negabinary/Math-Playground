extends HBoxContainer

var option : Justification.ExprItemOption
var context : AbstractParseBox
var parser : ExprItemParser2
var text_listener:Autostring


func _update():
	$Label.text = text_listener.get_string()


func init(option:Justification.ExprItemOption):
	self.option = option
	self.context = option.get_context()
	self.text_listener = (
		ExprItemAutostring.new(option.get_expr_item(), option.get_context())
		if option.get_expr_item() else
		ConstantAutostring.new("[not set.]")
	)
	text_listener.connect("updated", self,"_update")
	_update()
	$Button.connect("pressed", $ConfirmationDialog, "popup_centered")
	$ConfirmationDialog/VBoxContainer/TextEdit.connect("text_changed", self, "_validate")
	_validate()


func _validate():
	var string_to_parse = $ConfirmationDialog/VBoxContainer/TextEdit.text
	parser = ExprItemParser2.new(string_to_parse, context)
	if parser.error:
		$ConfirmationDialog.get_ok().disabled = true
		$ConfirmationDialog/VBoxContainer/Label.text = str(parser.error_dict)
	else:
		$ConfirmationDialog.get_ok().disabled = false
		$ConfirmationDialog.get_ok().connect("pressed", self, "ok")
		$ConfirmationDialog/VBoxContainer/Label.text = ""

func ok():
	option.set_expr_item(parser.result)
