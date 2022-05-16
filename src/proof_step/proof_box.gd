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


#TODO: find instances and change
func _init(parent:ProofBox, definitions:=[], imports := {}, justifications := {}): #<ExprItemType,String>
	self.parent = parent
	for definition in definitions:
		self.definitions[definition.to_string()] = definition
		definition.connect("renamed", self, "_update_definition_name", [definition, definition.to_string()])
	self.imports = imports
	self.justifications = justifications


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


func add_assumption(assumption) -> void: # assumption:ProofStep
	var ei:ExprItem = assumption.get_statement().as_expr_item()
	assumption_statements.append(ei)

func add_assumption_statement(assumption) -> void:
	assumption_statements.append(assumption)


func get_assumptions() -> Array:
	var result := []
	
	for statement in assumption_statements:
		result.append(
			PROOF_STEP.new(
				statement, self, AssumptionJustification.new(self)
			)
		)
	return result


func get_all_assumptions() -> Array:
	var imported_assumptions := []
	for import in imports:
		imported_assumptions += import.get_all_assumptions()
	if parent == null or parent == GlobalTypes.PROOF_BOX:
		return get_assumptions() + imported_assumptions
	else:
		return get_assumptions() + parent.get_assumptions() + imported_assumptions


func get_starred_assumptions() -> Array:
	var result := []
	if parent != null and parent != GlobalTypes.PROOF_BOX:
		result = parent.get_starred_assumptions()
	for import in imports:
		result += import.get_starred_assumptions()
	var all_assumptions = get_assumptions()
	all_assumptions.invert()
	for assumption in all_assumptions:
		result.push_front(PROOF_STEP.new(
			assumption.get_statement().as_expr_item(), self, AssumptionJustification.new(self)
		))
	all_assumptions.invert()
	return result


func check_assumption(proof_step):
	if _any_assumption_matches(proof_step):
		return true
	for import in imports:
		if import.check_assumption(proof_step):
			return true
	if parent != null:
		return parent.check_assumption(proof_step)
	else:
		return false


func _any_assumption_matches(proof_step):
	for assumption in assumption_statements:
		if assumption.compare(proof_step.get_statement().as_expr_item()):
			return true
	return false


func get_parent() -> ProofBox:
	return parent
	

# SERIALIZING ============================================

