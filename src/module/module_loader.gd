extends Node
class_name ModuleLoader

var modules := {}
var PATH_PRE := "res://lib/"
var PATH_SUF := ".tres"


func get_module(module_name:String, module_content = null) -> MathModule:
	if module_name in modules:
		return modules[module_name]
	else:
		if module_content == null:
			var f = File.new()
			f.open("res://lib/"+module_name+".tres",File.READ)
			var module = ModuleDeserializer.new(f.get_as_text(), module_name, self).get_module()
			f.close()
			modules[module_name] = module
			return module
		else:
			var module = ModuleDeserializer.new(module_content, module_name, self).get_module()
			modules[module_name] = module
			return module
