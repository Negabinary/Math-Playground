extends IdentifierBuilder
class_name IdentifierListener

# To listener
signal renamed
signal deleted

func _init(identifier:String, overrides:=0, module:="").(identifier, overrides, module):
	pass

func notify_rename():
	emit_signal("renamed")

func notify_delete():
	emit_signal("deleted")
