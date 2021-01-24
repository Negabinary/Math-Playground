extends VBoxContainer

onready var menu_button:MenuButton = $TopLine/MenuButton
onready var menu_popup := menu_button.get_popup()
#onready var ui_docstring_editor := $TopLine/LineEdit
onready var ui_exclamation := $TopLine/Exclamation
onready var statement_editor := $TopLine/ExprItemEdit
onready var ui_prove_buttom := $TopLine/Button
onready var ui_assume_button := $TopLine/AssumeButton

var theorem_item : ModuleItemTheorem

func _ready():
	menu_popup.connect("index_pressed", self, "_on_menu_item")
	#ui_docstring_editor.connect("text_changed", self, "_on_docstring_changed")
	statement_editor.connect("expr_item_changed", self, "_on_statement_changed")


func set_theorem_item(theorem_item:ModuleItemTheorem, typed:=true):
	statement_editor = $TopLine/ExprItemEdit
	ui_exclamation = $TopLine/Exclamation
	ui_prove_buttom = $TopLine/Button
	ui_assume_button = $TopLine/AssumeButton
	self.theorem_item = theorem_item
	var proof_box = theorem_item.get_module().get_proof_box(theorem_item.get_index())
	#$TopLine/LineEdit.text = theorem_item.get_docstring()
	$TopLine/ExprItemEdit.set_expr_item(theorem_item.get_statement(), proof_box)
	ui_assume_button.pressed = theorem_item.get_is_axiom()
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
	var valid = !statement_editor.has_holes()
	
	ui_exclamation.text = "" if valid else "!"
	ui_prove_buttom.disabled = !valid or ui_assume_button.pressed


func _on_prove():
	$"../../../../../../../..".enter_proof_mode(theorem_item.get_proof())


func _on_assume():
	theorem_item.set_is_axiom(ui_assume_button.pressed)
	_check_valid()
