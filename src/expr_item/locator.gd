extends Object
class_name Locator


var root_expr_item : ExprItem
var expr_item : ExprItem
var indeces : Array
var parent : Locator
var abandon := 0


func _init(new_root_expr_item, new_indeces:=[], new_expr_item:ExprItem=null, parent=null, abandon=0):
	self.root_expr_item = new_root_expr_item
	self.indeces = new_indeces
	self.parent = parent
	if self.parent == null and new_indeces.size() > 1:
		self.parent = get_script().new(new_root_expr_item, new_indeces.slice(0, new_indeces.size()-2))
	elif self.parent == null and new_indeces.size() == 1:
		self.parent = get_script().new(new_root_expr_item, [])
	self.abandon = abandon
	if new_expr_item == null:
		expr_item = new_root_expr_item
	else:
		expr_item = new_expr_item

func get_parent()->Locator:
	return parent


func get_parent_type() -> ExprItemType:
	return null if parent == null else parent.get_type()


func get_indeces() -> Array: #<Int>
	return indeces


func get_abandon() -> int:
	return abandon


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


func get_all_types() -> Dictionary:
	return expr_item.get_all_types()


func get_child(idx:int) -> Locator:
	var new_indeces := indeces.duplicate()
	new_indeces.push_back(idx)
	return get_script().new(root_expr_item, new_indeces, expr_item.get_child(idx), self)


func abandon_lowest(n:int) -> Locator:
	return get_script().new(root_expr_item, indeces, expr_item.abandon_lowest(n), self, abandon + n)


# Should work for both proof boxes and parse boxes
func get_proof_box(root_proof_box):
	if parent == null:
		return root_proof_box
	elif parent.get_type().get_binder_type() == ExprItemType.BINDER.BINDER and get_indeces()[-1] == 1:
		return root_proof_box.get_script().new(
			parent.get_proof_box(root_proof_box),
			[parent.get_child(0).get_type()]
		)
	else:
		return parent.get_proof_box(root_proof_box)


func get_outside_definitions() -> Array: #<ExprItemType>
	if parent == null:
		return []
	elif parent.get_type().get_binder_type() == ExprItemType.BINDER.BINDER and get_indeces()[-1] == 1:
		var outside_parent := parent.get_outside_definitions()
		outside_parent.append(parent.get_child(0).get_type())
		return outside_parent
	else:
		return parent.get_outside_definitions()


func _to_string():
	return expr_item.to_string()


func find_all(find:ExprItem) -> Array: #<Locator>
	if get_type() == find.get_type():
		if get_child_count() >= find.get_child_count():
			if abandon_lowest(get_child_count() - find.get_child_count()).get_expr_item().compare(find):
				var occ := [abandon_lowest(get_child_count() - find.get_child_count())]
				for c in range(find.get_child_count(), get_child_count()):
					occ += get_child(c).find_all(find)
				return occ
	var result = []
	for i in get_child_count():
		result += get_child(i).find_all(find)
	return result


func get_postorder_locator_list(list=[]):
	for child_id in get_child_count():
		get_child(child_id).get_postorder_locator_list(list)
	list.append(self)
	return list
