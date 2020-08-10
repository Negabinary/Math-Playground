extends Tree

signal change_selected_proof_entry

var proof_entry_map : Dictionary  # <TreeItem, ProofEntry>

func _ready():
	var w2 = ExprItem.from_string("=>(For all(X,=(+(0,X),X)),=>(For all(X,For all(Y,=(+(S(X),Y),+(X,S(Y))))),=>(=(S(0),1),=>(=(S(1),2),=>(=(S(2),3),=>(=(S(3),4),=(+(2,2),4)))))))")
	w2 = ExprItem.from_string("=>(A,A)")
	var expression = Statement.new(w2)
	
	var i1 = create_item()
	i1.set_custom_color(0, Color.white)
	proof_entry_map[i1] = ProofEntry.new(expression, [], [])#, [a, b])
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


func use_assumption(assumption:Statement):
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


func _on_assumption_refine(assumption:Statement, definition:ExprItemType, locator:UniversalLocator):
	var new_assumption = assumption.deep_replace_types({definition:locator.get_expr_item()})
	var selected_item := get_selected()
	var selected_proof_entry:ProofEntry = proof_entry_map[selected_item]
	
	if locator.get_statement() != assumption:
		selected_proof_entry.add_derived_assumption(new_assumption)
		_on_item_selected()


func _on_Equality_pressed():
	var selected_item := get_selected()
	var selected_goal:Statement = proof_entry_map[selected_item].get_goal()
	proof_entry_map[selected_item].acted = true
	selected_item.clear_custom_color(0)
	
	var selected_locator := UniversalLocator.new(selected_goal)
	var lhs := selected_locator.get_child(0)
	var rhs := selected_locator.get_child(1)
	
	if lhs.get_child_count() == 0:
		_mark_proven(selected_item)
	else:
		for i in lhs.get_child_count():
			var new_proof_entry = ProofEntry.new(
				Statement.new(
					ExprItem.new(
						GlobalTypes.EQUALITY,
						[lhs.get_child(i).get_expr_item(), rhs.get_child(i).get_expr_item()]
					)
				), [], []
			)
			var new_item = create_item(selected_item)
			new_item.set_custom_color(0, Color.white)
			proof_entry_map[new_item] = new_proof_entry
			new_item.set_text(0, new_proof_entry.get_goal().to_string())
			if i == 0:
				new_item.select(0)


func use_equality(position:UniversalLocator, equality:UniversalLocator):
	var selected_item := get_selected()
	var selected_goal:Statement = proof_entry_map[get_selected()].get_goal()
	
	proof_entry_map[selected_item].acted = true
	
	var new_statement := Statement.new(position.get_statement().as_expr_item().replace_at(position.get_indeces(), equality.get_expr_item()))
	var new_item = create_item(selected_item)
	var new_proof_entry = ProofEntry.new(new_statement, [], [])
	new_item.set_custom_color(0, Color.white)
	new_item.set_text(0, new_statement.to_string())
	proof_entry_map[new_item] = new_proof_entry
	new_item.select(0)


func _on_assumption_used():
	pass # Replace with function body.
