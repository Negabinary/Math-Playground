class_name ParseAdditionListener

var type : ExprItemType


func _init(type_of_interest:ExprItemType):
	type = type_of_interest


func get_type() -> ExprItemType:
	return type


signal addition_notify
func notify_addition():
	emit_signal("addition_notify", type)
