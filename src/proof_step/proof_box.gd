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
var definitions := []  # Array<ExprItemType>
var assumptions := []  # Array<ProofStep>
var parse_dict : Dictionary # <String, ExprItemType>
var tags : Dictionary
var tagging_proof_steps : Dictionary #<ExprItemTagHelper,ProofStep>
var level : int
var module


func _init(definitions:Array, parent:ProofBox, module = null): #<ExprItemType,String>
	self.parent = parent
	if parent == null:
		level = 0
	else:
		level = parent.get_level() + 1
	self.definitions = definitions
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
	if parent == null or parent == GlobalTypes.PROOF_BOX:
		return get_definitions()
	else:
		return get_definitions() + parent.get_definitions()


func add_assumption(assumption) -> void: # assumption:ProofStep
	assumptions.append(assumption)
	if assumption.get_statement().as_expr_item().get_child_count() > 0:
		if is_tag(assumption.get_statement().as_expr_item().abandon_lowest(1)):
			add_tag(assumption)


func remove_assumption(assumption) -> void: # assumption:ProofStep
	assumptions.erase(assumption)


func get_assumptions() -> Array:
	return assumptions


func get_all_assumptions() -> Array:
	if parent == null or parent == GlobalTypes.PROOF_BOX:
		return get_assumptions()
	else:
		return get_assumptions() + parent.get_assumptions()


func get_assumptions_not_in_module() -> Array:
	if (parent == null or parent == GlobalTypes.PROOF_BOX) and module == null:
		return get_assumptions()
	elif module == null:
		return get_assumptions() + parent.get_assumptions_not_in_module()
	else:
		return []


func update_parse_dict():
	for definition in definitions:
		parse_dict[definition.get_identifier()] = definition


func parse(string:String) -> ExprItemType:
	if string in parse_dict:
		return parse_dict[string]
	elif parent != null:
		return parent.parse(string)
	else:
		return null


func get_full_parse_dict() -> Dictionary:
	var fpd = parent.get_full_parse_dict()
	for string in parse_dict:
		fpd[string] = parse_dict[string]
	return fpd


func get_all_types() -> Array:
	if parent == null:
		return definitions
	else:
		return definitions + parent.get_all_types()


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
	if parent != null:
		return parent.find_tag(expr, tagging_check)
	else:
		return null


func check_assumption(proof_step):
	if proof_step in assumptions:
		return true
	elif _any_assumption_matches(proof_step):
		return true
	elif parent != null:
		return parent.check_assumption(proof_step)
	else:
		return false


func _any_assumption_matches(proof_step):
	for assumption in assumptions:
		if assumption.get_statement().as_expr_item().compare(proof_step.get_statement().as_expr_item()):
			return true
	return false


func is_tag(expr:ExprItem):
	return find_tag(expr, ExprItem.new(GlobalTypes.TAG,[expr]))


func get_parent() -> ProofBox:
	return parent


func get_level() -> int:
	return level
