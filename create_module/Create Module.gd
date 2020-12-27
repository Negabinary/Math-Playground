extends PageContainer

onready var ui_module_name = $ScrollContainer/MarginContainer/PanelContainer/VBoxContainer/ModuleName
onready var ui_requirements = $ScrollContainer/MarginContainer/PanelContainer/VBoxContainer/Requirements
onready var ui_enter_requirement = $ScrollContainer/MarginContainer/PanelContainer/VBoxContainer/AddRequirement/LineEdit
onready var ui_content = $ScrollContainer/MarginContainer/PanelContainer/VBoxContainer/Content


var module_loader : ModuleLoader = ModuleLoader.new()
var module


func _ready():
	_load_module(MathModule.new("current_module"))


func _load_module(module:MathModule):
	self.module = module
	ui_module_name.text = module.get_name().replace("_", " ").capitalize()
	ui_requirements.set_module(module)
	ui_content.set_module(module)


func add_requirement(req_name := ui_enter_requirement.text):
	if req_name != "":
		var new_module : MathModule = module_loader.get_module(req_name)
		if new_module != null:
			module.append_requirement(new_module)
			ui_enter_requirement.text = ""


func add_definition():
	var new_definition = ModuleItemDefinition.new(
			module,
			null,
			ExprItemType.new("")
		)
	module.append_item(new_definition)
	ui_content.add_definition(
		new_definition
	)


func add_theorem():
	var new_theorem = ModuleItemTheorem.new(
		module,
		null
	)
	module.append_item(new_theorem)
	ui_content.add_theorem(new_theorem)
