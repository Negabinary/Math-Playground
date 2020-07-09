extends Tree

signal proof_step_selected

var proof_step_map := {}
var root_ps : ProofStep

func _ready():
	connect("item_selected", self, "_on_item_selected")
	

func display_proof(root_proof_step:ProofStep):
	root_ps = root_proof_step
	_clear()
	_display_proof_step(root_proof_step)


func _get_next_unproven() -> TreeItem:
	if get_root() == null:
		return null
	else:
		var to_visit = [get_root()]
		while to_visit.size() > 0:
			var next:TreeItem = to_visit.pop_front()
			if proof_step_map[next].needs_justification():
				return next
			var c := next.get_children()
			while c != null:
				to_visit.push_front(c)
				c = c.get_next()
		return null


func _clear():
	for tree_item in proof_step_map:
		proof_step_map[tree_item].disconnect("justified", self, "_on_update")
	proof_step_map = {}
	clear()


func _display_proof_step(proof_step:ProofStep, parent:TreeItem=null):
	var new_item = create_item(parent)
	new_item.set_custom_color(0, Color.white if proof_step.needs_justification() else (Color.green if proof_step.is_proven() else Color.gray))
	new_item.set_text(0, proof_step.to_string())
	proof_step_map[new_item] = proof_step
	proof_step.connect("justified", self, "_on_update")
	for req in proof_step.get_requirements():
		_display_proof_step(req, new_item)


func _on_item_selected():
	var tree_item := get_selected()
	emit_signal("proof_step_selected", proof_step_map[tree_item])


func _on_update():
	display_proof(root_ps)
	_get_next_unproven().select(0)
