extends Object
class_name ProofBox

# TODO: NEW MEMBERS:

var parent : ProofBox

var imports := {} # <ProofBox>
var definitions := {}  # <String, ExprItemType>
var justifications := {} # <[unique]String, Justification>
var expr_items := {} # <[unique]String, ExprItem>

# TODO: OLD MEMBERS:

var PROOF_STEP = load("res://src/proof_step/proof_step.gd")


#TODO: find instances and change AND change add_assumptions underneath
#TODO: we'll have to check the assumptions match up at some point...
func _init(parent:ProofBox, definitions:=[], assumptions:=[], imports:={}): #<ExprItemType,String>
	self.parent = parent
	for definition in definitions:
		self.definitions[definition.to_string()] = definition
		definition.connect("renamed", self, "_update_definition_name", [definition, definition.to_string()])
	self.imports = imports
	self.justifications = {}
	for assumption in assumptions:
		add_justification(assumption, AssumptionJustification.new(self))


func get_parent() -> ProofBox:
	return parent


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
	return definitions.values()


func _update_definition_name(definition:ExprItemType, old_name:String):
	definitions.erase(old_name)
	definition.disconnect("renamed", self, "_update_definition_name")
	definition.connect("renamed", self, "_update_definition_name", [definition, definition.to_string()])
	definitions[definition.to_string()] = definition


func is_defined(type:ExprItemType):
	if type in get_definitions():
		return true
	for import in imports:
		if import.is_defined(type):
			return true
	return parent.is_defined(type)


func parse(string:String) -> ExprItemType:
	if string in definitions:
		return definitions[string]
	for import in imports:
		var p = import.parse(string)
		if p != null:
			return p
	if parent != null:
		return parent.parse(string)
	else:
		return null


# JUSTIFICATION ===========================================


signal justified # (uname)
signal proven # (uname)
signal unproven # (uname)


func add_justification(expr_item:ExprItem, justification):
	var uname = expr_item.get_unique_name()
	justifications[uname] = justification
	expr_items[uname] = expr_item
	justification.connect("proven", self, "_on_justification_proven")
	justification.connect("unproven", self, "_on_justification_unproven")
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


# TODO: Check circular
func is_proven(expr_item:ExprItem):
	var justification = _get_justification_for(expr_item.get_unique_name())
	if justification == null:
		return false
	else:
		return justification.can_prove(expr_item)


func _get_justification_for(expr_item_uid:String):
	var justification = justifications.get(expr_item_uid)
	if justification != null:
		return justification
	for import in imports:
		justification = import._get_justification_for(expr_item_uid)
		if justification != null:
			return justification
	if parent != null:
		return parent._get_justification_for(expr_item_uid)
	return null


func _on_justification_proven(uname:String):
	emit_signal("proven", uname)

func _on_justification_unproven(uname:String):
	emit_signal("unproven", uname)
