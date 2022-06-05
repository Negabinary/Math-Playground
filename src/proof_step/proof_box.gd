extends Object
class_name ProofBox

# TODO: NEW MEMBERS:

var parent : ProofBox

var imports := {} # <ProofBox>
var parse_box : ParseBox
var justifications := {} # <[unique]String, Justification>
var expr_items := {} # <[unique]String, ExprItem>
var children := {} # <String [requirement label], ExprItem>


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


static func _get_unique_label(definitions:Array, assumptions:Array) -> String:
	var label = str(definitions.size()) + ";"
	for assumption in assumptions:
		label += assumption.get_unique_name(definitions) + ";"
	return label


func get_child_extended_with(definitions:=[], assumptions:=[]) -> ProofBox:
	if definitions.size() == 0 and assumptions.size() == 0:
		return self
	var label := _get_unique_label(definitions, assumptions)
	if not (label in children):
		children[label] = get_script().new(self, definitions, assumptions)
	return children[label]


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
	var uname = expr_item.get_unique_name(get_definitions())
	justifications[uname] = justification
	expr_items[uname] = expr_item
	emit_signal("justified", uname)


func get_assumptions() -> Array: #<ExprItem>
	var result := []
	for ustring in justifications:
		#if justifications[ustring] is AssumptionJustification:
		result.append(expr_items[ustring])
	return result


func get_all_assumptions() -> Array:
	var imported_assumptions := []
	for import in imports:
		imported_assumptions += imports[import].get_all_assumptions()
	if parent == null:
		return get_assumptions() + imported_assumptions
	else:
		return get_assumptions() + parent.get_assumptions() + imported_assumptions


func get_all_assumptions_in_context() -> Array:
	var imported_assumptions := []
	for import in imports:
		imported_assumptions += imports[import].get_all_assumptions_in_context()
	var return_value = []
	for ass in get_assumptions():
		return_value.append([ass,self])
	if parent != null:
		return_value.append_array(parent.get_all_assumptions_in_context())
	return_value.append_array(imported_assumptions)
	return return_value


var MJ := load("res://src/proof_step/justifications/missing_justification.gd")


func get_justification_or_missing_for(expr_item:ExprItem):
	var j = get_justification_for(expr_item)
	if j:
		return j
	else:
		return MJ.new()


func get_justification_for(expr_item:ExprItem):
	var justification = justifications.get(expr_item.get_unique_name(get_definitions()))
	if justification != null:
		return justification
	var parent_justification = _get_parent_justification(expr_item)
	if parent_justification != null:
		return parent_justification
	return null


func _get_parent_justification(expr_item:ExprItem):
	for import in imports:
		var justification = imports[import].get_justification_for(expr_item)
		if justification != null:
			return justification
	if parent != null:
		return parent.get_justification_for(expr_item)
	return null


func is_ancestor_of(other:ProofBox):
	if self == other:
		return true
	elif other.parent == null:
		return false
	else:
		return is_ancestor_of(other.parent)


func get_uid(expr_item:ExprItem):
	return expr_item.get_unique_name(get_definitions())
