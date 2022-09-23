extends CheckBox
class_name DependencyOption

var dependency : ProofStep
var autostring : Autostring
var small := false
var index : int

func _init(dependency:ProofStep, autostring:Autostring, index:int, small := false):
	self.dependency = dependency
	self.autostring = autostring
	self.index = index
	self.small = small
	if small:
		add_font_override("font", get_font("font", "Label"))
	clip_text = true
	dependency.connect("proof_status", self, "_update")
	autostring.connect("updated", self, "_update")
	_update()
	dependency.get_parent().connect("active_dependency_changed", self, "_update_selection")
	_update_selection()
	connect("pressed", dependency.get_parent(), "set_active_dependency", [index])

func _update():
	text = autostring.get_string()
	theme_type_variation = "OptionTicked" if dependency.is_proven() else "OptionWarn"
#	if small:
#		add_icon_override("checked", get_icon("small"))
#		add_icon_override("checked_disabled", get_icon("small"))
#		add_icon_override("unchecked", get_icon("small"))
#		add_icon_override("unchecked_disabled", get_icon("small"))

func _update_selection():
	if dependency.get_parent().get_active_dependency() == index:
		pressed = true
		disabled = true
	else:
		pressed = false
		disabled = false
