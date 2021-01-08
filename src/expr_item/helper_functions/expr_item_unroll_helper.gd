class_name ExprItemUnrollHelper

static func get_shells(expr_item:ExprItem, type:ExprItemType) -> Array: #<Locator>
	


static func get_meat(expr_item:ExprItem, type:ExprItemType) -> Locator:
	var current_locator := Locator.new(expr_item)
	while expr_item.get_type() == type:
		current_locator 
