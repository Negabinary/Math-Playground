extends VBoxContainer

var proof_step : ProofStep
onready var main = $"../../../.."
onready var selection_handler = get_tree().get_nodes_in_group("selection_handler")[0]


func display_proof(proof_step:ProofStep):
	self.proof_step = proof_step
	_update()


func _update():
	_clear()
	_display_proof_step()


func _clear():
	if $Justification.get_child_count() != 0:
		var child = $Justification.get_child(0)
		$Justification.remove_child(child)
		child.queue_free()
		


func _display_proof_step():
	var j_box = build(proof_step, selection_handler)
	$Justification.add_child(j_box)

const WP_BOX = preload("res://ui/proof/written_proof_box/WPB2.tscn")

static func build(proof_step:ProofStep, selection_handler:SelectionHandler) -> Node:
	var node : Node = WP_BOX.instance()
	node.init(proof_step, selection_handler, WP_BOX)
	return node


func take_type_census(census:TypeCensus) -> TypeCensus:
	return proof_step.take_type_census(census)


func take_selection_for_top():
	$Justification.get_child(0).take_selection_for_top()
