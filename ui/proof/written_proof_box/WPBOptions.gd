extends VBoxContainer
class_name WPBOptions

signal request_change_justification # Justification

func set_options(options:Array) -> void:
	for child in get_children():
		child.deregister()
		remove_child(child)
	for option in options:
		pass
		# TODO: create option objects
