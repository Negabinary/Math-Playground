extends VBoxContainer

onready var menu_button:MenuButton = $TopLine/MenuButton
onready var menu_popup := menu_button.get_popup()
onready var ui_name_editor := $TopLine/LineEdit
onready var ui_colon_label := $TopLine/Label2
onready var ui_tag_editor:ExprItemEdit = $TopLine/ExprItemEdit
onready var ui_warning := $TopLine/Exclamation


var definition_item : ModuleItemDefinition


func _ready():
	menu_popup.connect("index_pressed", self, "_on_menu_item")
	ui_name_editor.connect("text_changed", self, "_on_name_changed")
	ui_tag_editor.connect("expr_item_changed", self, "_on_tag_changed")


func set_definition_item(definition_item:ModuleItemDefinition, typed:=true):
	self.definition_item = definition_item
	var proof_box = definition_item.get_module().get_proof_box(definition_item.get_index())
	$TopLine/ExprItemEdit.set_expr_item(definition_item.get_tag(), proof_box)
	$TopLine/LineEdit.text = definition_item.get_definition().get_identifier()


func _on_menu_item(idx:int):
	match idx:
		0:
			definition_item.delete()
		1:
			toggle_tagged()


func is_tagged() -> bool:
	return menu_popup.is_item_checked(menu_popup.get_item_index(1))


func toggle_tagged():
	menu_popup.set_item_checked(1, !menu_popup.is_item_checked(1))
	if is_tagged():
		ui_colon_label.show()
		ui_tag_editor.show()
	else:
		ui_colon_label.hide()
		ui_tag_editor.hide()
	_check_valid()
	


func _check_valid():
	ui_warning.text = "!" if \
		(is_tagged() && ui_tag_editor.has_holes()) \
		|| (ui_name_editor.text == "") \
	else ""


func _on_name_changed(new_name:String):
	definition_item.rename_type(new_name)
	_check_valid()


func _on_tag_changed():
	if ui_tag_editor.has_holes():
		definition_item.set_tag(null)
	else:
		definition_item.set_tag(ui_tag_editor.get_expr_item().apply(ExprItem.new(definition_item.get_definition())))
	_check_valid()
