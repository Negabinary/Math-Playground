extends IdentifierBuilder
class_name IdentifierListener

# To listener
signal updated
signal deleted

func _init(identifier:String, overrides:=0, module:="").(identifier, overrides, module):
	pass

func notify_rename():
	emit_signal("updated")

func notify_delete():
	emit_signal("deleted")
