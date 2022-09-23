extends HBoxContainer

var proof_step : ProofStep # final

func init(proof_step:ProofStep):
	self.proof_step = proof_step
	proof_step.connect("justification_properties_changed", self, "_refresh")
	_refresh()


func _refresh():
	for child in $HBoxContainer.get_children():
		$HBoxContainer.remove_child(child)
		child.queue_free()
	var justification = proof_step.get_justification()
	visible = not justification is MissingJustification
	if visible:
		var arr = justification.get_summary(proof_step.get_goal(), proof_step.get_inner_proof_box().get_parse_box())
		var deps = proof_step.get_dependencies()
		for item in arr:
			if item is Array:
				var child = DependencyOption.new(
					deps[item[0]],
					item[1],
					item[0],
					true
				)
				child.clip_text = false
				$HBoxContainer.add_child(child)
			elif item is Autostring:
				var child = AutostringLabel.new()
				child.autostring = item
				$HBoxContainer.add_child(child)
