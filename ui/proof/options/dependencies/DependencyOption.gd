extends CheckBox
class_name DependencyOption

var proof_step : ProofStep
var autostring : Autostring

func _init(proof_step:ProofStep):
	clip_text = true
	self.proof_step = proof_step
	proof_step.connect("proof_status", self, "_update")
	autostring = ExprItemAutostring.new(
		proof_step.get_goal(), proof_step.get_inner_proof_box().get_parse_box()
	)
	autostring.connect("updated", self, "_update")
	_update()

func _update():
	text = autostring.get_string()
	theme_type_variation = "OptionTicked" if proof_step.is_proven() else "OptionWarn"

func select():
	pressed = true
	disabled = true

func deselect():
	pressed = false
	disabled = false
