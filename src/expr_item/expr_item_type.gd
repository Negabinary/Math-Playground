extends Object
class_name ExprItemType


var identifier : String


func _init(ident:String, _type_info:=""):
	identifier = ident


func get_identifier():
	return identifier


func _to_string():
	return identifier
