extends ScrollContainer

var old_size : Vector2

func _ready():
	old_size = get_child(0).rect_size
	$MarginContainer.connect("resized", self, "_on_resized")

func _on_resized():
	var height_change = get_child(0).rect_size.y - old_size.y
	old_size = get_child(0).rect_size
	scroll_vertical = scroll_vertical + height_change


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_page_down"):
		_page_down()
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("ui_page_up"):
		_page_up()
		get_tree().set_input_as_handled()


func _page_down():
	scroll_vertical += rect_size.y


func _page_up():
	scroll_vertical -= rect_size.y
