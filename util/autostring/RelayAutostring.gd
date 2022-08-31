extends Autostring
class_name RelayAutostring

var other : Autostring


func _init(other:Autostring):
	self.other = other
	other.connect("updated", self, "emit_signal", ["updated"])


func set_autostring(other:Autostring) -> void:
	other.disconnect("updated", self, "emit_signal")
	self.other = other
	other.connect("updated", self, "emit_signal", ["updated"])
	emit_signal("updated")


func get_string() -> String:
	return other.get_string()
