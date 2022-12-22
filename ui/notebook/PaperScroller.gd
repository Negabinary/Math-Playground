extends ScrollContainer


func _process(_delta):
	$TextureRect.rect_min_size = Vector2(0, $"%MarginContainer".get_rect().size.y)
	scroll_vertical = $"%ScrollContainer".scroll_vertical
