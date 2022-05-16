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
func _init(parent:ProofBox, definitions:=[], assumptions := [], imports := {}): #<ExprItemType,String>
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


func add_justification(expr_item:ExprItem, justification):
	var uname = expr_item.get_unique_name()
	justifications[uname] = justification
	expr_items[uname] = expr_item


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
	if parent == null or parent == GlobalTypes.PROOF_BOX:
		return get_assumptions() + imported_assumptions
	else:
		return get_assumptions() + parent.get_assumptions() + imported_assumptions


func get_justification_for(expr_item:ExprItem):
	return justifications.get(expr_item.get_unique_name())
