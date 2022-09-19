extends StarButton


var left := false


func init(assumption:ExprItem, assumption_context:SymmetryBox, selection_handler:SelectionHandler, left:=false):
	self.left = left
	.init(assumption, assumption_context, selection_handler)


func _should_display() -> bool:
	var conclusion := assumption.get_conclusion()
	return conclusion.get_type() == GlobalTypes.EQUALITY and conclusion.get_child_count() == 2


func _on_pressed():
	if pressed:
		var equality := assumption.get_conclusion()
		var x := equality.get_child(1 if left else 0).get_expr_item()
		var y := equality.get_child(0 if left else 1).get_expr_item()
		var impl = ExprItem.new(
			GlobalTypes.IMPLIES,
			[x,y]
		)
		var full_impl = equality.get_root().replace_at(
				equality.get_indeces(),
				equality.get_abandon(),
				impl
			)
		assumption_context.justification_box.set_justification(
			full_impl, 
			SeparateBiimplicationJustification.new(left)
		)
		selection_handler.assumption_pane.save_assumption(full_impl, assumption_context, self)
	else:
		selection_handler.assumption_pane.remove_assumption(self)
