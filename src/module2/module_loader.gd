extends Node

var cache := {} #<String, Modules>
var folder := "user://lib2/"
var suffix := ".mml"

func clear() -> void:
	cache = {}


func get_module(module_name:String) -> Module:
	if not (module_name in cache):
		load_module(module_name)
	return cache[module_name]


func _name_to_path(module_name:String) -> String:
	return folder + module_name.replace(".","/") + suffix


func load_module(module_name:String) -> void:
	var file = File.new()
	file.open(_name_to_path(module_name),File.READ)
	var contents = file.get_as_text()
	file.close()
	var json = JSON.parse(contents).result
	var proof_box = GlobalTypes.PROOF_BOX
	var module = Module.new(module_name)
	for cell in json.cells:
		module.deserialize_cell(cell)
	cache[module_name] = module
