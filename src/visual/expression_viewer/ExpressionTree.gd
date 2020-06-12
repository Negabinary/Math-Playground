extends Tree

signal expr_item_selected

var ITEM_HEIGHT = 24

var locator_map : Dictionary # <TreeItem, Locator>

func update_tree(root_expr_item_locator : Locator, active = false):
	clear()
	locator_map = {}
	
	var color = Color.white if active else Color.gray
	
	var count = 0
	var parents = {root_expr_item_locator:null}
	var dfs_queue = [root_expr_item_locator]
	while dfs_queue.size() > 0:
		count += 1
		var current_locator:Locator = dfs_queue.pop_front()
		var current_item = create_item(parents[current_locator])
		print(current_locator.get_expr_item().to_string())
		current_item.set_text(0, current_locator.get_expr_item().get_type_string())
		current_item.set_custom_color(0, color)
		locator_map[current_item] = current_locator
		var child_count := current_locator.get_child_count()
		for i in child_count:
			var child : Locator 
			child = current_locator.get_child(child_count - i - 1)
			dfs_queue.push_front(child)
			parents[child] = current_item


func _on_item_selected():
	var selected_item := get_selected()
	var selected_locator:Locator = locator_map[selected_item]
	emit_signal("expr_item_selected", selected_locator)
