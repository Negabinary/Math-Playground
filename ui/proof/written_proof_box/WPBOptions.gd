extends VBoxContainer
class_name WPBOptions

signal request_change_justification # Justification

const BOOLEAN_OPTION = preload("res://ui/proof/options/BooleanOption.tscn")
const BUTTON_OPTION = preload("res://ui/proof/options/ButtonOption.tscn")
const EXPR_ITEM_OPTION = preload("res://ui/proof/options/ExprItemOption.tscn")
const EXPR_ITEM_TYPE_NAME_OPTION = preload("res://ui/proof/options/ExprItemTypeNameOption.tscn")
const LABEL_OPTION = preload("res://ui/proof/options/LabelOption.tscn")
const LOCATOR_OPTION = null # TODO

func set_options(options:Array) -> void:
	for child in get_children():
		#child.deregister()
		remove_child(child)
	for option in options:
		var bo
		if option is Justification.BooleanOption:
			bo = BOOLEAN_OPTION.instance()
		elif option is Justification.ButtonOption:
			bo = BUTTON_OPTION.instance()
		elif option is Justification.ExprItemOption:
			bo = EXPR_ITEM_OPTION.instance()
		elif option is Justification.ExprItemTypeNameOption:
			bo = EXPR_ITEM_TYPE_NAME_OPTION.instance()
		elif option is Justification.LabelOption:
			bo = LABEL_OPTION.instance()
		elif option is Justification.LocatorOption:
			bo = LABEL_OPTION.instance()
			option = Justification.LabelOption.new("TODO")
		bo.init(option)
		add_child(bo)
