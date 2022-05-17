extends VBoxContainer

var requirement : Requirement
onready var main = $"../../../.."
onready var selection_handler = $"../../../../../../../../../../../../SelectionHandler"


func display_proof(requirement:Requirement):
	self.requirement = requirement
	_update()


func _update():
	_clear()
	_display_proof_step()


func _clear():
	if $Justification.get_child_count() != 0:
		$Justification.remove_child($Justification.get_child(0))


func _display_proof_step():
	var j_box = WrittenProofBoxBuilder.build(requirement, selection_handler)
	if not requirement.is_connected("justified", self, "_update"):
		requirement.connect("justified", self, "_update")
	$Justification.add_child(j_box)
