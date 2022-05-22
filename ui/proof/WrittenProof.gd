extends VBoxContainer

var requirement : Requirement
var proof_context : ProofBox
onready var main = $"../../../.."
onready var selection_handler = $"../../../../../../../../../../../../SelectionHandler"


func display_proof(context:ProofBox, requirement:Requirement):
	self.requirement = requirement
	self.proof_context = context
	_update()


func _update():
	_clear()
	_display_proof_step()


func _clear():
	if $Justification.get_child_count() != 0:
		$Justification.remove_child($Justification.get_child(0))


func _display_proof_step():
	# todo: check if proven
	var j_box = WrittenProofBoxBuilder.build(proof_context, requirement, selection_handler)
	$Justification.add_child(j_box)
