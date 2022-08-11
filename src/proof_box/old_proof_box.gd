extends ProofBox
class_name OldProofBox

# TODO: NEW MEMBERS:

var parent : ProofBox

var imports := {} # <ProofBox>
var parse_box : AbstractParseBox

var assumptions := [] #<ExprItem>
var scratch_justifications := {} # <[unique]String, Justification>
var scratch_expr_items := {} # <[unique]String, ExprItem>
var done_justifications := {}
var done_expr_items := {}


func _init(parent:ProofBox, definitions:=[], assumptions:=[], imports:={}): #<ExprItemType,String>
	self.parent = parent
	self.parse_box = ParseBox.new(parent.get_parse_box() if parent else RootParseBox.new(), definitions)
	for k in imports:
		var import_box : AbstractParseBox = imports[k].get_final_proof_box().get_parse_box()
		self.parse_box = ImportParseBox.new(self.parse_box, k, import_box, false)
	self.assumptions = assumptions
	self.imports = imports


func __get_parent() -> ProofBox:
	return parent


func get_uid(expr_item:ExprItem):
	return expr_item.get_unique_name()


func get_parse_box() -> AbstractParseBox:
	return parse_box


func is_ancestor_of(other:ProofBox):
	if self == other:
		return true
	elif other.parent == null:
		return false
	elif is_ancestor_of(other.parent):
		return true
	else:
		for import in other.imports:
			if is_ancestor_of(other.imports[import].get_final_proof_box()):
				return true
		return false


# IMPORTS =================================================


# returns null if name cannot be found
func find_import(import_name):
	var result = imports.get(import_name)
	if result:
		return result
	else:
		return __get_parent().find_import(import_name)


# DEFINITIONS =============================================


func get_definitions() -> Array:
	return parse_box.get_definitions()


func _update_definition_name(definition:ExprItemType, old_name:String) -> void:
	parse_box._update_definition_name(definition, old_name)


func parse(string:String) -> ExprItemType:
	return parse_box.parse_full(string)


# JUSTIFICATION ===========================================


# edit ----------------------------------------------------

signal justified # (uname)


func add_justification(expr_item:ExprItem, justification):
	var uname = expr_item.get_unique_name()
	scratch_justifications[uname] = justification
	scratch_expr_items[uname] = expr_item
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
