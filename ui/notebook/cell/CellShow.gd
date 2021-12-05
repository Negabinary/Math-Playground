extends VBoxContainer

var item

func initialise(item:ModuleItem2Theorem):
	$HBoxContainer3/Name.text = item.get_assumption().to_string()
	var root_ps := ProofStep.new(item.get_assumption(), item.get_current_proof_box())
	$Proof/WrittenProof.display_proof(root_ps)
