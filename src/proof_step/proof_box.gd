extends Object
class_name ProofBox

# TODO: NEW MEMBERS:

var parent : ProofBox

var imports := {} # <ProofBox>
var parse_box : ParseBox
var justifications := {} # <[unique]String, Justification>
var expr_items := {} # <[unique]String, ExprItem>


# TODO: find instances and change
# TODO: change add_assumptions underneath
# TODO: we'll have to check the assumptions match up at some point...
func _init(parent:ProofBox, definitions:=[], assumptions:=[], imports:={}): #<ExprItemType,String>
	self.parent = parent
	var parse_imports = {}
	for k in imports:
		parse_imports[k] = imports[k].get_parse_box()
	self.parse_box = ParseBox.new(parent.get_parse_box() if parent else null, definitions, parse_imports)
	self.imports = imports
	self.justifications = {}
	for assumption in assumptions:
		add_justification(assumption, AssumptionJustification.new())


func get_parent() -> ProofBox:
	return parent


func get_parse_box() -> ParseBox:
	return parse_box


# IMPORTS =================================================


# returns null if name cannot be found
func find_import(import_name):
	var result = imports.get(import_name)
	if result:
		return result
	else:
		return get_parent().find_import(import_name)


# DEFINITIONS =============================================


func get_definitions() -> Array:
	return parse_box.get_definitions()


func _update_definition_name(definition:ExprItemType, old_name:String) -> void:
	parse_box._update_definition_name(definition, old_name)


func is_defined(type:ExprItemType) -> bool:
	return parse_box.is_defined(type)


func parse(string:String) -> ExprItemType:
	return parse_box.parse(string)


# JUSTIFICATION ===========================================

signal justified # (uname)


func add_justification(expr_item:ExprItem, justification):
	var uname = expr_item.get_unique_name()
	justifications[uname] = justification
	expr_items[uname] = expr_item
	emit_signal("ei_justified", uname)


func get_assumptions() -> Array: #<ExprItem>
	var result := []
	for ustring in justifications:
		if justifications[ustring] is AssumptionJustification:
			result.append(expr_items[ustring])
	return result


func get_all_assumptions() -> Array:
	var imported_assumptions := []
	for import in imports:
		imported_assumptions += import.get_all_assumptions()
	if parent == null:
		return get_assumptions() + imported_assumptions
	else:
		return get_assumptions() + parent.get_assumptions() + imported_assumptions


var MJ := load("res://src/proof_step/justifications/missing_justification.gd")

func get_justification_or_missing(expr_item:ExprItem):
	var j = get_justification_for(expr_item)
	if j:
		return j
	else:
		return MJ.new()


func get_justification_for(expr_item:ExprItem):
	var justification = justifications.get(expr_item.get_unique_name())
	if justification != null:
		return justification
	var parent_justification = _get_parent_justification(expr_item)
	if parent_justification != null:
		if parent_justification.can_prove(expr_item):
			return parent_justification
	return null


func _get_parent_justification(expr_item:ExprItem):
	for import in imports:
		var justification = import.get_justification_for(expr_item)
		if justification != null:
			return justification
	if parent != null:
		return parent.get_justification_for(expr_item)
	return null
