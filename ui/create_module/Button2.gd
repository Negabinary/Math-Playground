extends Button


func _ready():
	connect("pressed", self, "_pressed")


func _pressed():
	$FileDialog.current_file = $"../../ModuleNameEdit".text.to_lower().replace(" ","_") + ".tres"
	$FileDialog.popup_centered()
