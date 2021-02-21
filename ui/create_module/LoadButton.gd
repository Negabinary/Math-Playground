extends Button


func _ready():
	connect("pressed", self, "_pressed")


func _pressed():
	$FileDialog2.invalidate()
	$FileDialog2.popup_centered()
