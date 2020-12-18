extends Object
class_name ExprItemType


var identifier : String
var binder := false

var fm_expected_args := 1
var fm_strings := []



func _init(ident:String, _type_info:=""):
	identifier = ident
	fm_strings = [identifier]


func get_identifier():
	return identifier


func _to_string():
	return identifier


func get_fm_arg_count():
	return fm_strings.size() -1


func get_fm_strings():
	return fm_strings
