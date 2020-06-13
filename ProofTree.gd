extends Tree

signal change_selected_proof_entry

var proof_entry_map : Dictionary  # <TreeNode, ProofEntry>

func _ready():
	var A = ExprItemType.new("A")
	var B = ExprItemType.new("B")
	var C = ExprItemType.new("C")
	
	var a = ExprItem.new(A)
	var b = ExprItem.new(B)
	var c = ExprItem.new(C)
	
	var a_impl_b = ExprItem.new(GlobalTypes.IMPLIES, [a, b])
	var b_impl_c = ExprItem.new(GlobalTypes.IMPLIES, [b, c])
	var a_impl_c = ExprItem.new(GlobalTypes.IMPLIES, [a, c])
	
	
	
	var AND = ExprItemType.new("and")
	var X = ExprItemType.new("X")
	var Y = ExprItemType.new("Y")
	var Z = ExprItemType.new("Z")
	
	var x = ExprItem.new(X)
	var y = ExprItem.new(Y)
	var z = ExprItem.new(Z)
	var x_n_y = ExprItem.new(AND, [x, y])
	var x_n_y_i_z = ExprItem.new(GlobalTypes.IMPLIES, [x_n_y, z])
	var y_i_z = ExprItem.new(GlobalTypes.IMPLIES, [y, z])
	var x_i_y_i_z = ExprItem.new(GlobalTypes.IMPLIES, [x, y_i_z])
	var cdl = ExprItem.new(GlobalTypes.IMPLIES, [x_n_y_i_z, x_i_y_i_z])
	var cdr = ExprItem.new(GlobalTypes.IMPLIES, [x_i_y_i_z, x_n_y_i_z])
	var conj_def_l = ExprItem.new(GlobalTypes.FORALL, [x, ExprItem.new(GlobalTypes.FORALL, [y, ExprItem.new(GlobalTypes.FORALL, [z, cdl])])])
	var conj_def_r = ExprItem.new(GlobalTypes.FORALL, [x, ExprItem.new(GlobalTypes.FORALL, [y, ExprItem.new(GlobalTypes.FORALL, [z, cdr])])])
	

	var a_impl_b_and_b_impl_c = ExprItem.new(AND, [a_impl_b, b_impl_c])
	var to_show = ExprItem.new(GlobalTypes.IMPLIES, [a_impl_b_and_b_impl_c, a_impl_c])
	
	var w1 = ExprItem.new(GlobalTypes.IMPLIES, [conj_def_r, to_show])
	var w2 = ExprItem.new(GlobalTypes.IMPLIES, [conj_def_l, w1])
	
	var expression = Statement.new(w2, [A, B, C])
	
	var i1 = create_item()
	i1.set_custom_color(0, Color.white)
	proof_entry_map[i1] = ProofEntry.new(expression, [], [a, b])
	i1.set_text(0, expression.to_string())


func _on_item_selected():
	var selected_item := get_selected()
	
	var proof_entries : Array = [proof_entry_map[selected_item]]
	while selected_item != get_root():
		selected_item = selected_item.get_parent()
		proof_entries.append(proof_entry_map[selected_item])
	
	emit_signal("change_selected_proof_entry", proof_entries)


func _on_Implication_pressed():
	var selected_item := get_selected()
	var selected_goal = proof_entry_map[selected_item].goal
	proof_entry_map[selected_item].acted = true
	selected_item.clear_custom_color(0)
	
	var lhs = selected_goal.get_child(0)
	var rhs = selected_goal.get_child(1)
	
	var new_proof_entry = ProofEntry.new(rhs, [lhs], [])
	var new_item = create_item(selected_item)
	new_item.set_custom_color(0, Color.white)
	proof_entry_map[new_item] = new_proof_entry
	new_item.set_text(0, rhs.to_string())
	
	new_item.select(0)


func _mark_proven(item:TreeItem) -> void:
	item.set_custom_color(0, Color.green)
	proof_entry_map[item].proven = true
	var parent := item.get_parent()
	if parent != null:
		var sibling := parent.get_children()
		while sibling != null:
			if !proof_entry_map[sibling].proven:
				return
			sibling = sibling.get_next()
		_mark_proven(parent)


func _on_assumption_used(assumption:Statement):
	var selected_item := get_selected()
	var selected_goal:Statement = proof_entry_map[selected_item].get_goal()
	
	if assumption.get_conclusion().get_expr_item().compare(selected_goal.as_expr_item()):
		var conditions = assumption.get_conditions()
		if conditions.size() == 0:
			_mark_proven(selected_item)
		else:
			proof_entry_map[selected_item].acted = true
			var is_first := true
			for condition in conditions:
				var new_expression = Statement.new(condition.get_expr_item())
				var new_item = create_item(selected_item)
				var new_proof_entry = ProofEntry.new(new_expression, [], [])
				new_item.set_custom_color(0, Color.white)
				new_item.set_text(0, new_expression.to_string())
				proof_entry_map[new_item] = new_proof_entry
				if is_first:
					new_item.select(0); is_first = false
