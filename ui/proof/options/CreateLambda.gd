extends VBoxContainer

signal update

onready var ui_replace : ExprItemEdit = $Replace/Replace
onready var ui_with : LineEdit = $With/With
onready var ui_preview :ExprItemEdit = $Preview/Preview

var new_type : ExprItemType
var locator : Locator
var argument_locations : Array
var argument_types : Array
var argument_values

var valid : bool

func setup(proof_step:ProofStep, locator:Locator, new_type:=ExprItemType.new("x")) -> void:
	self.locator = locator
	self.argument_types = [new_type]
	self.argument_locations = [[]]
	self.new_type = new_type
	self.argument_values = []
	var proof_box = locator.get_proof_box(proof_step.get_proof_box())
	ui_replace.set_expr_item(null, proof_box)
	ui_replace.connect("expr_item_changed", self, "_on_replace_changed")
	ui_with.set_text(new_type.get_identifier())
	ui_with.connect("text_changed", self, "_on_identifier_changed")
	ui_preview.set_expr_item(locator.get_root(), proof_step.get_proof_box()) # hrmmm shouldn't have to give it a proof_box...

func is_valid():
	return !ui_replace.has_holes()

func get_locator() -> Locator:
	return locator

func get_argument_locations() -> Array:
	return argument_locations

func get_argument_types() -> Array:
	return argument_types

func get_argument_values() -> Array:
	return argument_values

func _on_replace_changed():
	if !ui_replace.has_holes():
		argument_locations = [locator.find_all(ui_replace.get_expr_item())]
		argument_values = [ui_replace.get_expr_item()]
		var ei := ExprItemLambdaHelper.create_lambda(
			locator, argument_locations, argument_types, argument_values
		)
		ui_preview.set_expr_item(ei)
	emit_signal("update")

func _on_identifier_changed(_t):
	new_type.rename(ui_with.text)
