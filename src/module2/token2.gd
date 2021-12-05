class_name Token2

var from_char : int
var to_char : int
var contents : String

func _init(from_char:int, to_char:int, contents:String):
	self.from_char = from_char
	self.to_char = to_char
	self.contents = contents

func _to_string():
	return self.contents
