extends Control

func init(option:Justification.ExprItemTypeNameOption):
	$LineEdit.type = option.get_type()
