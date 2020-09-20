extends Node
class_name ModuleLoader

var modules := {}
var PATH_PRE := "res://lib/"
var PATH_SUF := ".tres"


func get_module(module_name:String) -> MathModule:
	if module_name in modules:
		return modules[module_name]
	else:
		var f = File.new()
		f.open("res://lib/"+module_name+".tres",File.READ)
		var module = MathModule.new(f, module_name, self)
		f.close()
		modules[module_name] = module
		return module
