class_name IdentifierBuilder

var module := ""
var overrides := 0
var identifier : String # final

func _init(identifier:String, overrides:=0, module:=""):
	self.identifier = identifier 
	self.overrides = overrides
	self.module = module


static func parse(IB, full_name:String) -> IdentifierBuilder:
	var split := full_name.split(".",true)
	if split.size() == 1:
		return IB.new(full_name)
	else:
		var ident := split[-1]
		split.remove(split.size() - 1)
		var module := ""
		var overrides := 0
		for s in split:
			if s == "":
				overrides += 1
			else:
				if module != "":
					module = module + "."
				module += s
		return IB.new(ident, overrides, module)


# Queries =================================================

func get_identifier() -> String:
	return identifier


func get_override_count() -> int:
	return overrides


func is_overriden() -> bool:
	return overrides != 0


func has_module() -> bool:
	return module != ""


func get_module() -> String:
	return module


# Edits ===================================================

func override(amt:=1) -> void:
	overrides += amt


func deoverride(amt:=1) -> void:
	overrides -= amt


func set_module(module:String) -> void:
	self.module = module


func remove_module() -> void:
	self.module = ""


# Result ==================================================

func get_full_string() -> String:
	var result = identifier
	for i in overrides:
		result = "." + result
	if module != "":
		result = "." + result
	return module + result
