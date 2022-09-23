extends VBoxContainer
class_name WPBRequirements

signal requirement_selected # int

var proof_step : ProofStep
var requirements : Array


func init(proof_step:ProofStep):
	self.proof_step = proof_step
	proof_step.connect("dependencies_changed", self, "_update")
	_update()


func _update():
	self.proof_step = proof_step
	requirements = proof_step.get_dependencies()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for i in len(requirements):
		var autostring = ExprItemAutostring.new(
			requirements[i].get_goal(), requirements[i].get_inner_proof_box().get_parse_box()
		)
		var child = DependencyOption.new(requirements[i], autostring, i)
		add_child(child)
