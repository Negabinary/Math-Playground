extends Object
class_name Locator


var root_expr_item : ExprItem
var expr_item : ExprItem
var indeces : Array
var parent : Locator


func _init(new_root_expr_item, new_indeces:=[], new_expr_item:ExprItem=null, parent=null):
	self.root_expr_item = new_root_expr_item
	self.indeces = new_indeces
	self.parent = parent
	if new_expr_item == null:
		expr_item = new_root_expr_item
	else:
		expr_item = new_expr_item


func get_parent()->Locator:
	return parent


func get_indeces():
	return indeces


func is_root():
	return indeces == []


func get_root() -> ExprItem:
	return root_expr_item


func get_expr_item() -> ExprItem:
	return expr_item


func get_child_count() -> int:
	return expr_item.get_child_count()


func get_type() -> ExprItemType:
	return expr_item.get_type()


func get_child(idx:int) -> Locator:
	var new_indeces := indeces.duplicate()
	new_indeces.push_back(idx)
	return get_script().new(root_expr_item, new_indeces, expr_item.get_child(idx), self)


func get_proof_box(root_proof_box:ProofBox):
	if parent == null:
		return root_proof_box
	elif parent.get_type().is_binder() and get_indeces()[-1] == 1:
		return ProofBox.new(
			[parent.get_child(0).get_type()],
			parent.get_proof_box(root_proof_box)
		)
	else:
		return parent.get_proof_box(root_proof_box)


func _to_string():
	return expr_item.to_string()


func find_all(find:ExprItem) -> Array: #<Locator>
	if expr_item.compare(find):
		return [self]
	else:
		var result = []
		for i in get_child_count():
			result += get_child(i).find_all(find)
		return result


func get_postorder_locator_list(list=[]):
	for child_id in get_child_count():
		get_child(child_id).get_postorder_locator_list(list)
	list.append(self)
	return list
