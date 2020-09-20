extends Object
class_name MathModule


var name : String
var definitions := []
var proof_steps := []
var requirements := []


func _init(file : File, new_name:String, module_loader):
	name = new_name
	var current_item = []
	var statement_strings = []
	while not file.eof_reached():
		var line = file.get_line().strip_edges(false,true)	
		if line.begins_with("@R "):
			_parse_requirement(line.right(3), module_loader)
			current_item = []
		if line.begins_with("@D "):
			_parse_definition(line.right(3))
			current_item = []
		elif line.begins_with("@> "):
			statement_strings.append(_parse_statement(current_item, line))
			current_item = []
		elif line.begins_with("@A ") or \
				line.begins_with("@E ") or \
				line.begins_with("@< ") or \
				line.begins_with("@= "):
			current_item.push_front(line)
	
	var def_dict := get_definition_dict()
	var scope := GlobalTypes.get_scope_stack().new_child_context(def_dict)
	for requirement in requirements:
		scope.put_all(requirement.get_definition_dict())
	for statement_string in statement_strings:
		var expr_item := ExprItemBuilder.from_string(statement_string, scope)
		var proof_step = ProofStep.new(expr_item)
		proof_step.justify_with_module(self)
		proof_steps.append(proof_step)


func _parse_requirement(requirement:String, module_loader):
	requirements.append(module_loader.get_module(requirement.strip_edges(true,true)))


func get_proof_steps():
	return proof_steps


func get_definitions() -> Array:
	return definitions


func get_requirements() -> Array:
	return requirements


func get_name() -> String:
	return name


func get_definition_dict() -> Dictionary:
	var def_dict := {}
	for i in definitions:
		def_dict[i.get_identifier()] = i
	return def_dict


func _parse_definition(def_line:String):
	var def_name : String = def_line.split(":")[0].strip_edges(true,true)
	var type_info : String = def_line.split(":")[1].strip_edges(true,true)
	definitions.append(ExprItemType.new(def_name, type_info))


func _parse_statement(qualifiers:Array, conclusion) -> String:
	var string = conclusion.right(3)
	for qualifier in qualifiers:
		var qualifier_type = qualifier.left(3)
		var qualifier_payload = qualifier.right(3)
		print(qualifier_type)
		if qualifier_type == "@A ":
			var def_name : String = qualifier_payload.split(":")[0].strip_edges(true,true)
			var type_info : String = qualifier_payload.split(":")[1].strip_edges(true,true)
			string = "For all(" + def_name + "," + string + ")"
		elif qualifier_type == "@E ":
			var def_name : String = qualifier_payload.split(":")[0].strip_edges(true,true)
			var type_info : String = qualifier_payload.split(":")[1].strip_edges(true,true)
			string = "For some(" + def_name + "," + string + ")"
		elif qualifier_type == "@< ":
			string = "=>(" + qualifier_payload + "," + string + ")"
		elif qualifier_type == "@= ":
			string = "=(" + qualifier_payload + "," + string + ")"
	return string
