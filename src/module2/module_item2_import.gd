extends ModuleItem2
class_name ModuleItem2Import

var module
var name : String
var error := false
var ipbox : ImportParseBox

func _init(context:SymmetryBox, name:String, namespace:=false):
	module = Module2Loader.get_module(name)
	if module:
		ipbox = ImportParseBox.new(
			context.get_parse_box(),
			name,
			module.get_final_proof_box().get_parse_box(),
			namespace
		)
		# Todo: switch this to .get_child_extended_with()
		proof_box = SymmetryBox.new(
			ImportJustificationBox.new(
				context.get_justification_box(),
				name,
				module.get_final_proof_box().get_justification_box()
			),
			ipbox
		)
		self.name = name
	else:
		error = true


func get_all_definitions(recursive:bool) -> Array: #<EIT>
	if recursive:
		return module.get_all_definitions()
	else:
		return []


func get_all_assumptions(recursive:bool) -> Array: #<EI>
	if recursive:
		return module.get_all_assumptions()
	else:
		return []


func get_all_theorems(recursive:bool) -> Array: #<EI>
	if recursive:
		return module.get_all_theorems()
	else:
		return []


func get_all_imports(recursive:bool) -> Array: #<String>
	if recursive:
		return module.get_all_imports() + [module.get_name()]
	else:
		return [module.get_name()]


func get_import_name() -> String:
	return module.get_name()


func get_final_proof_box() -> SymmetryBox:
	return module.get_proof_box()


func is_using_namespace() -> bool:
	return ipbox.is_using_namespace()

func set_namespace(val:bool) -> void:
	ipbox.set_namespace(val)


func get_module():
	return module


func serialise():
	return {kind="import", module=name, namespace=ipbox.is_using_namespace()}


func take_type_census(census:TypeCensus) -> TypeCensus:
	var all_types:TwoWayParseMap = module.get_final_proof_box().get_parse_box().get_all_types()
	for type in all_types.get_all_types():
		census.remove_entry(type)
	return census
