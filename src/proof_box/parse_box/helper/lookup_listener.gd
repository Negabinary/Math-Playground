class_name LookupListener

var key
var value

func _init(key, value):
	self.key = key
	self.value = value

func get_key():
	return key

func get_value():
	return value

signal updated
func notify():
	emit_signal("updated", key)
