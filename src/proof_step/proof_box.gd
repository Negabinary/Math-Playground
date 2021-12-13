extends Object
class_name ProofBox

"""
ProofBox

There are multiple layers and types of ProofBox:

Layers n+1 ~ n+m : Locator

Layers 3 ~ n : Justification

Layer 2 : Module

Layer 1 : Requirements

Layer 0 : Global
"""

#signal definition_added
#signal definition_deleted
#signal assumption_added
#signal assumption_deleted


var parent : ProofBox
var name : String

var definitions := []  # Array<ExprItemType>
var assumption_statements : Array
var imports := []
const stars := {}
var parse_dict : Dictionary # <String, ExprItemType>
var tags : Dictionary
var tagging_proof_steps : Dictionary #<ExprItemTagHelper,ProofStep>
var level : int
var module

var PROOF_STEP = load("res://src/proof_step/proof_step.gd")


func _init(definitions:Array, parent:ProofBox, module = null, name = "", assumption_statements := [], imports := []): #<ExprItemType,String>
	self.parent = parent
	self.name = name
	self.imports = imports
	if parent == null:
		level = 0
	else:
		level = parent.get_level() + 1
	self.definitions = definitions
	self.assumption_statements = assumption_statements
	self.module = module
	update_parse_dict()
	for definition in definitions:
		definition.connect("renamed", self, "update_parse_dict")


func get_module():
	if module != null:
		return module
	elif parent != null:
		return parent.get_module()
	else:
		return null


func add_definition(definition:ExprItemType) -> void:
	definitions.append(definition)
	definition.connect("renamed", self, "update_parse_dict")
	update_parse_dict()


func remove_definition(definition:ExprItemType) -> void:
	definition.disconnect("renamed", self, "update_parse_dict")
	definitions.erase(definition)


func get_definitions() -> Array:
	return definitions


func get_all_definitions() -> Array:
	var imported_definitions := []
	for import in imports:
		imported_definitions += import.get_all_definitions()
	if parent == null or parent == GlobalTypes.PROOF_BOX:
		return get_definitions() + imported_definitions
	else:
		return get_definitions() + parent.get_definitions() + imported_definitions


func add_assumption(assumption, star=true) -> void: # assumption:ProofStep
	var ei:ExprItem = assumption.get_statement().as_expr_item()
	assumption_statements.append(ei)
	#TODO: tagging
	if star:
		stars[ei] = self


func add_assumption_statement(assumption, star=true) -> void:
	assumption_statements.append(assumption)
	#TODO: tagging
	if star:
		stars[assumption] = self


func remove_assumption(assumption) -> void: # assumption:ProofStep
	assumption_statements.erase(assumption.get_statement().as_expr_item())
	stars.erase(assumption.get_statement().as_expr_item())


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
	var all_assumptions = get_assumptions()
	all_assumptions.invert()
	for assumption in all_assumptions:
		if stars.has(assumption.get_statement().as_expr_item()):
			result.push_front(PROOF_STEP.new(
				assumption.get_statement().as_expr_item(), self, AssumptionJustification.new(self)
			))
	all_assumptions.invert()
	return result


func update_parse_dict():
	for definition in definitions:
		parse_dict[definition.get_identifier()] = definition


func parse(string:String) -> ExprItemType:
	if string in parse_dict:
		return parse_dict[string]
	for import in imports:
		var p = import.parse(string)
		if p != null:
			return p
	if parent != null:
		return parent.parse(string)
	else:
		return null


func get_full_parse_dict() -> Dictionary:
	var fpd = parent.get_full_parse_dict().duplicate()
	for import in imports:
		var ifpd = import.get_full_parse_dict()
		for k in ifpd:
			fpd[k] = ifpd[k]
	for string in parse_dict:
		fpd[string] = parse_dict[string]
	return fpd


func get_all_types() -> Array:
	return get_all_definitions()


func add_tag(tagging) -> void: # tagging:ProofStep
	var tag_helper := ExprItemTagHelper.new(tagging.get_statement().as_expr_item())
	var type := tag_helper.get_tagged_type()
	if tags.has(type):
		tags[type] += [tag_helper]
	else:
		tags[type] = [tag_helper]
	tagging_proof_steps[tag_helper] = tagging
#	assert (find_tag(ExprItem.new(type), tagging.get_statement().as_expr_item()) != null)


func find_tag(expr:ExprItem, tagging_check:ExprItem): # -> ProofStep
	if tags.has(expr.get_type()):
		for type_taging in tags[expr.get_type()]:
			if expr.get_child_count() == 0:
				return tagging_proof_steps[type_taging]
			else:
				if type_taging.get_return_tag(expr.get_child_count()-1).get_expr_item().compare(tagging_check.abandon_lowest(1)):
					#return tagging_proof_steps[type_taging]
					#assert(false)
					pass
	for import in imports:
		if import.find_tag(expr, tagging_check) != null:
			return import.find_tag(expr, tagging_check)
	if parent != null:
		return parent.find_tag(expr, tagging_check)
	else:
		return null


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


func is_tag(expr:ExprItem):
	return find_tag(expr, ExprItem.new(GlobalTypes.TAG,[expr]))


func get_parent() -> ProofBox:
	return parent


func get_level() -> int:
	return level
