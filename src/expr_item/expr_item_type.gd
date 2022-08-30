extends Object
class_name ExprItemType


signal renamed
signal deleted


var identifier : String
enum BINDER {NOT_BINDER, BINDER}
var binder : int = BINDER.NOT_BINDER

var fm_expected_args := 1
var fm_strings := []
var two_line := false
var uid:int
const _singleton := {counter = 0}
#var n := int(rand_range(0,99))


static func _get_id() -> int:
	_singleton.counter = _singleton.counter + 1
	return _singleton.counter


func _init(ident:String, _type_info:=""):
	identifier = ident
	fm_strings = [identifier]
	uid = _get_id()


func get_uid() -> int:
	return uid


func is_binder() -> bool:
	return binder == BINDER.BINDER


func rename(new_name:String):
	if new_name == "":
		new_name = "???"
	identifier = new_name
	fm_strings = [identifier]
	emit_signal("renamed")


func get_identifier() -> String:
	return identifier

func _to_string():
	return identifier # + str(n)


func get_fm_arg_count():
	return fm_strings.size() -1


func get_fm_strings():
	return fm_strings


func get_binder_type() -> int:
	return binder


func delete():
	emit_signal("deleted")


func serialize():
	return get_identifier()
