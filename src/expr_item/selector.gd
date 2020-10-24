extends Object
class_name Selector


var root_locator : Locator
var dropped_children : int
var excluded : Array # <Selector>


func _init(root_locator, dropped_children := 0, excluded := []):
	self.root_locator = root_locator
	self.dropped_children = dropped_children
	self.excluded = excluded
