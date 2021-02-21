extends Button


func _ready():
	connect("pressed", self, "_pressed")


func _pressed():
	$FileDialog.invalidate()
	$FileDialog.current_file = $"../../ModuleNameEdit".text.to_lower().replace(" ","_") + ".mml"
	$FileDialog.popup_centered()
