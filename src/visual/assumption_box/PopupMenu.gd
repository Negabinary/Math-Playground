extends PopupMenu

signal prove

func _ready():
	add_item("Prove")
	connect("index_pressed", self, "_on_index_pressed")

func _on_index_pressed(idx:int):
	if idx == 0:
		emit_signal("prove")
