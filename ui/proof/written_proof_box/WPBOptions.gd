extends GridContainer
class_name WPBOptions

const BOOLEAN_OPTION = preload("res://ui/proof/options/BooleanOption.tscn")
const BUTTON_OPTION = preload("res://ui/proof/options/ButtonOption.tscn")
const EXPR_ITEM_OPTION = preload("res://ui/proof/options/ExprItemOption.tscn")
const EXPR_ITEM_TYPE_NAME_OPTION = preload("res://ui/proof/options/ExprItemTypeNameOption.tscn")
const LABEL_OPTION = preload("res://ui/proof/options/LabelOption.tscn")

var options:Array

func set_options(options:Array) -> void:
	self.options = options
	for child in get_children():
		#child.deregister()
		remove_child(child)
	for option in self.options:
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
		bo.init(option)
		add_child(bo)
	queue_sort()
