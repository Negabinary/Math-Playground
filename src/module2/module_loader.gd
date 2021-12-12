extends Node

var cache := {}
var folder := "user://lib2/"
var suffix := ".mml"

func clear() -> void:
	cache = {}

func get_module(module_name:String) -> ProofBox:
	if not (module_name in cache):
		load_module(module_name)
	return cache[module_name]

func _name_to_path(module_name:String) -> String:
	return folder + module_name.replace(".","/") + suffix

func load_module(module_name:String) -> void:
	var file = File.new()
	print(_name_to_path(module_name))
	file.open(_name_to_path(module_name),File.READ)
	var contents = file.get_as_text()
	file.close()
	var json = JSON.parse(contents).result
	var proof_box = GlobalTypes.PROOF_BOX
	for cell in json.cells:
		if cell.compiled:
			for item in cell.items:
				proof_box = deserialise_item(item, proof_box).get_next_proof_box()
	cache[module_name] = proof_box


static func deserialise_item(item, proof_box:ProofBox) -> ModuleItem2:
		var module_item : ModuleItem2
		if item.kind == "definition":
			return ModuleItem2Definition.new(
				proof_box, 
				ExprItemType.new(item.type)
			)
		elif item.kind == "assumption":
			return ModuleItem2Assumption.new(
				proof_box, 
				ExprItemBuilder.from_string(item.expr, proof_box)
			)
		elif item.kind == "theorem":
			return ModuleItem2Theorem.new(
				proof_box, 
				ExprItemBuilder.from_string(item.expr, proof_box),
				item.proof
			)
		elif item.kind == "import":
			return ModuleItem2Import.new(
				proof_box,
				item.module
			)
		else:
			assert(false)
			return null
