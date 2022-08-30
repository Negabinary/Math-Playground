class_name Locator


var root_expr_item : ExprItem
var indeces : Array
var abandon := 0


func _init(new_root_expr_item, new_indeces:=[], abandon=0):
	self.root_expr_item = new_root_expr_item
	self.indeces = new_indeces
	self.abandon = abandon


func _get_indeces_tail():
	var x = indeces.duplicate()
	x.pop_back()
	return x


func get_parent() -> Locator:
	if indeces.size() > 0:
		return get_script().new(root_expr_item, _get_indeces_tail())
	else:
		return null


func get_parent_type() -> ExprItemType:
	return null if indeces.size() == 0 else get_parent().get_type()


func get_indeces() -> Array: #<Int>
	return indeces


func get_abandon() -> int:
	return abandon


func is_root():
	return indeces == []


func get_root() -> ExprItem:
	return root_expr_item


func get_expr_item() -> ExprItem:
	var result := root_expr_item
	for index in indeces:
		result = result.get_child(index)
	return result


func get_child_count() -> int:
	return get_expr_item().get_child_count()


func get_type() -> ExprItemType:
	return get_expr_item().get_type()


func get_all_types() -> Dictionary:
	return get_expr_item().get_all_types()


func get_child(idx:int) -> Locator:
	var new_indeces := indeces.duplicate()
	new_indeces.push_back(idx)
	return get_script().new(root_expr_item, new_indeces)


func abandon_lowest(n:int) -> Locator:
	return get_script().new(root_expr_item, indeces, abandon + n)


func get_outside_definitions() -> Array: #<ExprItemType>
	var current_ei := root_expr_item
	var cuml_definitions := []
	for index in indeces:
		if index == 1 and current_ei.get_type().is_binder():
			cuml_definitions.append(current_ei.get_child(0).get_type())
		current_ei = current_ei.get_child(index)
	return cuml_definitions


func get_proof_box(root_proof_box):
	var definitions = get_outside_definitions()
	return root_proof_box.get_child_extended_with(definitions)


func get_parse_box(root_parse_box:AbstractParseBox) -> AbstractParseBox:
	var definitions = get_outside_definitions()
	return ParseBox.new(root_parse_box, definitions)


func _to_string():
	return get_expr_item().to_string()


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
