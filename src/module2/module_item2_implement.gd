extends ModuleItem2
class_name ModuleItem2Implement

var module
var name : String
var definition : ExprItemType
var assumption : ExprItem
var error := ""
var missing_imports := []
var import_error


func _init(context:SymmetryBox, name:String, definition:ExprItemType):
	self.name = name
	module = Module2Loader.get_module(name)
	if !module:
		error = "module"
		return
	var module_imports = module.get_all_imports(false)
	for mi in module_imports:
		var has_import = context.get_parse_box().has_import(mi)
		if not has_import.value:
			missing_imports.append(mi)
		context.get_parse_box().remove_import_listener(has_import)
	if len(missing_imports) > 0:
		error = "imports"
		return
	self.definition = definition
	assumption = module.get_as_statement(definition)
	if !assumption:
		error = "empty"
		return
	proof_box = context.get_child_extended_with(
		[definition], [assumption]
	)


func get_import_name() -> String:
	return module.get_name()


func get_new_name_eit() -> ExprItemType:
	return definition


func get_assumption() -> ExprItem:
	return assumption


func get_module():
	return module


func serialise():
	return {kind="implement", module=name, new_name=definition.get_identifier()}


func take_type_census(census:TypeCensus) -> TypeCensus:
	census.add_entry("assumption", self, assumption.get_all_types())
	census.remove_entry(definition)
	return census


func get_all_definitions(recursive:bool) -> Array: #<EI>
	return [definition]


func get_all_assumptions(recursive:bool) -> Array: #<EI>
	return [assumption]
