extends HBoxContainer
#
#
#func update_buttons(proof_entry:ProofEntry):
#	if !proof_entry.has_been_acted_on():
#		var root_locator := UniversalLocator.new(proof_entry.get_goal())
#		var root_type := root_locator.get_expr_item().get_type()
#		if root_type == GlobalTypes.IMPLIES:
#			$Implication.disabled = false
#		else:
#			$Implication.disabled = true
#		if root_type == GlobalTypes.EQUALITY:
#			if root_locator.get_child(0).get_type() == root_locator.get_child(1).get_type() and get_child(1).get_child_count() == get_child(0).get_child_count():
#				$Equality.disabled = false
#			else:
#				$Equality.disabled = true
#		else:
#			$Equality.disabled = true
#	else:
#		$Implication.disabled = true
