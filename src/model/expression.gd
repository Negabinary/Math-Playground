extends Object
class_name Expr

var definitions : Array # <ExprItemType>
var root : ExprItem

func _init(new_root:ExprItem, new_definitions:=[]):
	root = new_root
	definitions = new_definitions


func get_root() -> ExprItem:
	return root


func get_definitions() -> Array:
	return definitions


func _to_string() -> String:
	return root.to_string()
