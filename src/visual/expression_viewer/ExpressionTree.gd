extends Tree

signal expr_item_selected

var ITEM_HEIGHT = 24

var locator_map : Dictionary # <TreeItem, UniversalLocator>

func update_tree(root_expr_item_locator : UniversalLocator, active = false):
	clear()
	locator_map = {}
	
	var color = Color.white if active else Color.gray
	
	var count = 0
	var parents = {root_expr_item_locator:null}
	var dfs_queue = [root_expr_item_locator]
	while dfs_queue.size() > 0:
		count += 1
		var current_locator:UniversalLocator = dfs_queue.pop_front()
		var current_item = create_item(parents[current_locator])
		current_item.set_text(0, current_locator.get_type().to_string())
		current_item.set_custom_color(0, color)
		locator_map[current_item] = current_locator
		var child_count := current_locator.get_child_count()
		for i in child_count:
			var child : UniversalLocator 
			child = current_locator.get_child(child_count - i - 1)
			dfs_queue.push_front(child)
			parents[child] = current_item


func _on_item_selected():
	var selected_item := get_selected()
	var selected_locator:UniversalLocator = locator_map[selected_item]
	emit_signal("expr_item_selected", selected_locator)


func get_drag_data(position):
	var item = get_item_at_position(position)
	if item != null:
		var locator = locator_map[item]
		return locator
