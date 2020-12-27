extends VBoxContainer

export (PackedScene) var DEFINITION_SCENE

var module : MathModule


func set_module(module:MathModule):
	self.module = module


func add_definition(definition_item:ModuleItemDefinition):
	var new_def_edit = DEFINITION_SCENE.instance()
	new_def_edit.set_definition_item(definition_item)
	add_child(new_def_edit)
	definition_item.connect("request_delete", self, "_on_item_deleted", [new_def_edit])


func _on_item_deleted(child):
	remove_child(child)
