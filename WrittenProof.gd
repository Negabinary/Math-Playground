extends VBoxContainer

var root_ps : ProofStep
onready var main = $"../../../.."
onready var selection_handler = $"../../../../../../SelectionHandler"


func display_proof(root_proof_step:ProofStep):
	root_ps = root_proof_step
	_update()


func _update():
	_clear()
	_display_proof_step()


func _clear():
	if $Justification.get_child_count() != 0:
		$Justification.remove_child($Justification.get_child(0))


func _display_proof_step():
	var j_box = WrittenProofBoxBuilder.build(root_ps, selection_handler)
	if not root_ps.is_connected("justified", self, "_update"):
		root_ps.connect("justified", self, "_update")
	$Justification.add_child(j_box)
