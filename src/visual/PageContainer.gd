extends Container
class_name PageContainer

export var page_width := 1000

func _get_minimum_size():
	if get_child_count() == 0:
		return Vector2(0,0)
	else:
		return get_child(0).get_combined_minimum_size()

func _ready():
	connect("sort_children", self, "_sort_children")
	connect("item_rect_changed", self, "_sort_children")
	_sort_children()

func _sort_children():
	var self_size = rect_size
	var width = min(page_width, rect_size.x)
	var height = rect_size.y
	print(str(width,",",height))
	get_combined_minimum_size()
	fit_child_in_rect(
		get_child(0),
		Rect2(
			(rect_size.x - width) / 2,
			0,
			width,
			height
		)
	)
