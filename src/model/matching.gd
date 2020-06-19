extends Object
class_name Matching

const ANY = "*"

var alpha : UniversalLocator
var beta : UniversalLocator
var alpha_map := {}
var beta_map := {}
var possible := true


func _init(new_alpha:UniversalLocator, new_beta:UniversalLocator):
	alpha = new_alpha
	beta = new_beta
	_initialise_definitions(alpha.get_definitions(), alpha_map)
	_initialise_definitions(beta.get_definitions(), beta_map)
	possible = _compute_matching_at(alpha, alpha_map, beta, beta_map)
	for def in alpha_map:
		if alpha_map[def] is String:
			var new_def := ExprItemType.new(def.get_identifier())
			alpha_map[def] = ExprItem.new(new_def)
	for def in beta.get_definitions():
		if beta_map[def] is String:
			var new_def := ExprItemType.new(def.get_identifier())
			beta_map[def] = ExprItem.new(new_def)


func _initialise_definitions(definitions:Array, map:Dictionary):
	for definition in definitions:
		map[definition] = ANY


func _compute_matching_at(
		gamma:UniversalLocator, 
		gamma_map:Dictionary, 
		delta:UniversalLocator,
		delta_map) -> bool:
	
	var gamma_type = gamma.get_type()
	var delta_type = delta.get_type()
	if gamma_type in gamma.get_definitions():
		if gamma_map[gamma_type] == ANY: 
			gamma_map[gamma_type] = delta.get_expr_item()
			return true
		else:
			assert (false)
			return false
			return _compute_matching_at(gamma_map[gamma_type], delta_map, delta, delta_map)
	else:
		if gamma_type != delta_type:
			return false
		if gamma.get_child_count() != delta.get_child_count():
			return false
		for i in gamma.get_child_count():
			if not _compute_matching_at(gamma.get_child(i), gamma_map, delta.get_child(i), delta_map):
				return false
		return true


func get_alpha_replacements() -> Dictionary:
	return alpha_map


func get_alpha_new_definitions() -> Array:
	return [] # MUST CHANGE; THIS IS WRONG!


#func create_hybrid() -> Statement:
#	var new_definitions = []
#	for def in alpha_map:
#		if alpha_map[def] is String:
#			var new_def := ExprItemType.new(def.get_identifier())
#			alpha_map[def] = ExprItem.new(new_def)
#			new_definitions.append(new_def)
#	for def in beta.get_definitions():
#		if beta_map[def] is String:
#			var new_def := ExprItemType.new(def.get_identifier())
#			beta_map[def] = ExprItem.new(new_def)
#			new_definitions.append(new_def)
#
#	var new_expr_item := _deep_replace_alpha_expr_item(alpha.get_statement().get_conclusion().get_expr_item())
#	for condition in alpha.get_statement().get_conditions():
#		new_expr_item = ExprItem.new(GlobalTypes.IMPLIES, [_deep_replace_alpha_expr_item(condition.get_expr_item()), new_expr_item])
#
#	return Statement.new(new_expr_item, new_definitions)


func _deep_replace_alpha_expr_item(expr_item:ExprItem) -> ExprItem:
	var new_children := []
	for i in expr_item.get_child_count():
		var child := expr_item.get_child(i)
		new_children.append(_deep_replace_alpha_expr_item(child))
	
	if expr_item.get_type() in alpha_map:
		return alpha_map[expr_item.get_type()]
	else:
		return ExprItem.new(expr_item.get_type(), new_children)


func is_possible() -> bool:
	return possible
