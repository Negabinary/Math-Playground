extends VBoxContainer

var selection_handler : SelectionHandler

func _ready():
	selection_handler = get_tree().get_nodes_in_group("selection_handler")[0]
	selection_handler.connect("wpb_changed", self, "_update")
	_update()

func _update():
	var wpb : WrittenProofBox2 = selection_handler.get_wpb()
	if wpb:
		var proof_step := wpb.get_proof_step()
		if proof_step.get_justification() is MissingJustification:
			get_parent().set_tab_hidden(1,true)
			get_parent().current_tab = 0
		else:
			get_parent().set_tab_hidden(1,false)
			get_parent().current_tab = 1
			$"%JustificationOptions".init(proof_step, selection_handler)
	else:
		get_parent().set_tab_hidden(1,true)
		get_parent().current_tab = 0
