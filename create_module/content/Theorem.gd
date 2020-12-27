extends VBoxContainer

onready var menu_button:MenuButton = $TopLine/MenuButton
onready var menu_popup := menu_button.get_popup()
onready var ui_docstring_editor := $TopLine/LineEdit
onready var ui_exclamation := $BottomLine/Exclamation
onready var statement_editor := $BottomLine/ExprItemEdit

var theorem_item : ModuleItemTheorem

func _ready():
	menu_popup.connect("index_pressed", self, "_on_menu_item")
	ui_docstring_editor.connect("text_changed", self, "_on_docstring_changed")
	statement_editor.connect("expr_item_changed", self, "_on_statement_changed")


func set_theorem_item(theorem_item:ModuleItemTheorem, typed:=true):
	statement_editor = $BottomLine/ExprItemEdit
	ui_exclamation = $BottomLine/Exclamation
	self.theorem_item = theorem_item
	var proof_box = theorem_item.get_module().get_proof_box(theorem_item.get_index())
	$TopLine/LineEdit.text = theorem_item.get_docstring()
	$BottomLine/ExprItemEdit.set_expr_item(theorem_item.get_statement(), proof_box)
	_check_valid()


func _on_menu_item(idx:int):
	match idx:
		0:
			theorem_item.delete()


func _on_statement_changed():
	if !statement_editor.has_holes():
		theorem_item.update_statement(statement_editor.get_expr_item())
	_check_valid()


func _check_valid():
	ui_exclamation.text = "!" if \
	statement_editor.has_holes() \
	else ""
