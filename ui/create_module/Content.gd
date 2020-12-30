extends VBoxContainer

export (PackedScene) var DEFINITION_SCENE
export (PackedScene) var THEOREM_SCENE

var module : MathModule


func set_module(module:MathModule):
	self.module = module
	for child in get_children():
		remove_child(child)
	for item in module.get_items():
		if item is ModuleItemDefinition:
			add_definition(item)
		elif item is ModuleItemTheorem:
			add_theorem(item)
		else:
			assert (false)


func add_definition(definition_item:ModuleItemDefinition):
	var new_def_edit = DEFINITION_SCENE.instance()
	new_def_edit.set_definition_item(definition_item)
	add_child(new_def_edit)
	definition_item.connect("request_delete", self, "_on_item_deleted", [new_def_edit])


func add_theorem(theorem_item:ModuleItemTheorem):
	var new_theo_edit = THEOREM_SCENE.instance()
	new_theo_edit.set_theorem_item(theorem_item)
	add_child(new_theo_edit)
	theorem_item.connect("request_delete", self, "_on_item_deleted", [new_theo_edit])


func _on_item_deleted(child):
	remove_child(child)
