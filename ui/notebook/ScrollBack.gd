extends ScrollContainer

var old_size : Vector2

func _ready():
	old_size = get_child(0).rect_size
	$MarginContainer.connect("resized", self, "_on_resized")

func _on_resized():
	var height_change = get_child(0).rect_size.y - old_size.y
	old_size = get_child(0).rect_size
	scroll_vertical = scroll_vertical + height_change
