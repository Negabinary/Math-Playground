extends HBoxContainer


func update_buttons(proof_entry:ProofEntry):
	if !proof_entry.has_been_acted_on():
		var root_locator := UniversalLocator.new(proof_entry.get_goal())
		var root_type := root_locator.get_expr_item().get_type()
		if root_type == GlobalTypes.IMPLIES:
			$Implication.disabled = false
		else:
			$Implication.disabled = true
	else:
		$Implication.disabled = true
