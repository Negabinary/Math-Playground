class_name ForallHelper


var root : ExprItem
var definitions : Array # <ExprItemType>
var without : ExprItem


func _init(new_root:ExprItem): 
	root = new_root
	definitions = []
	without = _get_without_definitions(new_root)


func _get_without_definitions(expr_item:ExprItem):
	if expr_item.get_type() == GlobalTypes.FORALL and expr_item.get_child_count() == 2:
		definitions.append(expr_item.get_child(0).get_type())
		return _get_without_definitions(expr_item.get_child(1))
	elif expr_item.get_type() == GlobalTypes.IMPLIES and expr_item.get_child_count() == 2:
		return ExprItem.new(GlobalTypes.IMPLIES, [
			expr_item.get_child(0),
			_get_without_definitions(expr_item.get_child(1))
		])
	else:
		return expr_item


func get_definitions() -> Array:
	return definitions


func get_conclusion_with_conditions() -> ExprItem:
	return without
