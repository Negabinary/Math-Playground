extends Object
class_name MatchingTwo

var alpha : UniversalLocator
var beta : UniversalLocator
var alpha_map : Dictionary = {}

var possible := true

# Where alpha is the more general one
# Thus beta maps are not a thing!!

func _init(new_alpha:UniversalLocator, new_beta:UniversalLocator):
	alpha = new_alpha
	beta = new_beta
	if alpha.get_child_count() == 0:
		_merge_map({alpha.get_type():beta.get_expr_item()})
	elif alpha.get_child_count() == beta.get_child_count():
		if alpha.get_type() != beta.get_type():
			if alpha.get_type() in alpha.get_definitions():
				_merge_map({alpha.get_type():beta.get_type()})
			else:
				possible = false
		for i in alpha.get_child_count():
			if not possible:
				break
			var child_matching:MatchingTwo = get_script().new(alpha.get_child(i), beta.get_child(i))
			_merge_map(child_matching.get_map())
	else:
		possible = false


func get_map() -> Dictionary:
	return alpha_map


func _merge_map(with:Dictionary):
	for alpha_type in with:
		if not possible:
			return
		if not (alpha_type in alpha_map):
			alpha_map[alpha_type] = with[alpha_type]
		elif alpha_map[alpha_type] is ExprItemType and with[alpha_type] is ExprItemType:
			if alpha_map[alpha_type] == with[alpha_type]:
				pass
			else:
				assert (false) # Yeah this one's too complicated for me now
				possible = false
		elif alpha_map[alpha_type] is ExprItem and with[alpha_type] is ExprItem:
			if alpha_map[alpha_type].compare(with[alpha_type]):
				pass
			else:
				assert (false) # Too complicated also
				possible = false
		else:
			assert (false) # Too complicated again
			possible = false


func get_alpha_replacements() -> Dictionary:
	return alpha_map


func get_alpha_new_definitions() -> Array:
	return beta.get_definitions() # MUST CHANGE; THIS IS WRONG!
