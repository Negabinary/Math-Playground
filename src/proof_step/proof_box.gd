extends Object
class_name ProofBox

# TODO: NEW MEMBERS:

var parent : ProofBox

var imports := {} # <ProofBox>
var parse_box : ParseBox

var assumptions := [] #<ExprItem>
var scratch_justifications := {} # <[unique]String, Justification>
var scratch_expr_items := {} # <[unique]String, ExprItem>
var done_justifications := {}
var done_expr_items := {}

var children := {} # <String [requirement label], ExprItem>
var children_defs := {} # <String [requirement label], Array<ExprItemType>>


func _init(parent:ProofBox, definitions:=[], assumptions:=[], imports:={}): #<ExprItemType,String>
	self.parent = parent
	var parse_imports = {}
	for k in imports:
		parse_imports[k] = imports[k].get_final_proof_box().get_parse_box()
	self.parse_box = ParseBox.new(parent.get_parse_box() if parent else null, definitions, parse_imports)
	self.assumptions = assumptions
	self.imports = imports


func get_parent() -> ProofBox:
	return parent


static func _get_unique_label(definitions:Array, assumptions:Array) -> String:
	var label := str(definitions.size()) + ":"
	for assumption in assumptions:
		label += assumption.get_unique_name(definitions) + ";"
	return label


func get_child_extended_with(definitions:=[], assumptions:=[]) -> ProofBox:
	if definitions.size() == 0 and assumptions.size() == 0:
		return self
	var label := _get_unique_label(definitions, assumptions)
	if not (label in children):
		children[label] = get_script().new(self, definitions, assumptions)
		children_defs[label] = definitions
	return children[label]


func convert_requirement(r:Requirement) -> Requirement:
	var old_defs := r.get_definitions()
	var old_asss := r.get_assumptions()
	var label := _get_unique_label(old_defs, old_asss)
	if label in children_defs:
		var new_defs:Array = children_defs[label]
		assert(old_defs.size() == new_defs.size())
		var map := {}
		for i in old_defs.size():
			map[old_defs[i]] = ExprItem.new(new_defs[i])
		var new_asss := []
		for ass in old_asss:
			new_asss.append(ass.deep_replace_types(map))
		return Requirement.new(
			r.get_goal().deep_replace_types(map),
			new_defs,
			new_asss
		)
	else:
		return r


func get_uid(expr_item:ExprItem):
	return expr_item.get_unique_name()


func get_parse_box() -> ParseBox:
	return parse_box


func is_ancestor_of(other:ProofBox):
	if self == other:
		return true
	elif other.parent == null:
		return false
	else:
		return is_ancestor_of(other.parent)


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


# edit ----------------------------------------------------

signal justified # (uname)


func add_justification(expr_item:ExprItem, justification):
	var uname = expr_item.get_unique_name()
	scratch_justifications[uname] = justification
	scratch_expr_items[uname] = expr_item
	emit_signal("justified", uname)


func add_done_justification(expr_item:ExprItem, justification):
	var uname = expr_item.get_unique_name()
	done_justifications[uname] = justification
	done_expr_items[uname] = expr_item
	emit_signal("justified", uname)


# get -----------------------------------------------------

var MJ := load("res://src/proof_step/justifications/missing_justification.gd")

func get_justification_or_missing_for(expr_item:ExprItem):
	var j = get_justification_for(expr_item)
	if j:
		return j
	else:
		j = MJ.new()
		add_justification(expr_item, j)
		return j


func get_justification_for(expr_item:ExprItem):
	if _is_assumed(expr_item):
		return AssumptionJustification.new()
	var justification = scratch_justifications.get(expr_item.get_unique_name())
	if justification != null:
		return justification
	return _get_done_justification(expr_item)


func _is_assumed(expr_item:ExprItem):
	for assumption in assumptions:
		if expr_item.compare(assumption):
			return true
	for import in imports:
		if imports[import].get_final_proof_box()._is_assumed(expr_item):
			return true
	if parent != null:
		return parent._is_assumed(expr_item)
	else:
		return false


func _get_done_justification(expr_item:ExprItem):
	var justification = done_justifications.get(expr_item.get_unique_name())
	if justification != null:
		return justification
	for import in imports:
		var ijustification = imports[import].get_final_proof_box()._get_done_justification(expr_item)
		if ijustification != null:
			return ijustification
	if parent != null:
		return parent._get_done_justification(expr_item)
	return null


func _get_parent_justification(expr_item:ExprItem):
	for import in imports:
		var justification = imports[import].get_final_proof_box().get_justification_for(expr_item)
		if justification != null:
			return justification
	if parent != null:
		return parent.get_justification_for(expr_item)
	return null


# list ----------------------------------------------------


func get_all_known_results() -> Array:
	var akr := assumptions + done_expr_items.values()
	for import in imports:
		akr.append_array(imports[import].get_final_proof_box().get_all_known_results())
	if parent != null:
		akr.append_array(parent.get_all_known_results())
	return akr
