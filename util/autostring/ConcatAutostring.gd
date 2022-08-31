extends Autostring
class_name ConcatAutostring

var values := []


func _init(values:Array): # <Autostring + String>
	self.values = values
	for value in values:
		if value is Autostring:
			value.connect("updated", self, "emit_signal", ["updated"])


func get_string() -> String:
	var result := ""
	for value in values:
		result = result + str(value)
	return result
