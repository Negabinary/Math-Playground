class_name ForallHelper


var root : ExprItem
var definitions : Array # <ExprItemType>
var without : ExprItem


func _init(new_root:ExprItem): 
	root = new_root
	definitions = []
	without = _get_without_definitions(new_root)


func _get_without_definitions(expr_item:ExprItem) -> ExprItem:
	if expr_item.get_type() == GlobalTypes.FORALL and expr_item.get_child_count() == 2:
		definitions.append(expr_item.get_child(0).get_type())
		return _get_without_definitions(expr_item.get_child(1))
	elif expr_item.get_type() == GlobalTypes.IMPLIES and expr_item.get_child_count() == 2:
		var conj_terms := []
		var conj_terms_toexplore := [expr_item.get_child(0)]
		while not conj_terms_toexplore.empty():
			var next : ExprItem = conj_terms_toexplore.pop_front()
			if next.get_type() == GlobalTypes.AND and next.get_child_count() == 2:
				conj_terms_toexplore.push_front(next.get_child(1))
				conj_terms_toexplore.push_front(next.get_child(0))
			else:
				conj_terms.push_front(next)
		var result := _get_without_definitions(expr_item.get_child(1))
		for k in conj_terms:
			result = ExprItem.new(GlobalTypes.IMPLIES, [
				k,
				result
			])
		return result
	else:
		return expr_item


func get_definitions() -> Array:
	return definitions


func get_conclusion_with_conditions() -> ExprItem:
	return without
