extends Autostring
class_name ConstantAutostring

var value := ""


func _init(value:String):
	self.value = value


func get_string() -> String:
	return value
