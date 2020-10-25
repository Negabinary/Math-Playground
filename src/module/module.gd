extends Object
class_name MathModule


var name : String
var proof_steps := []
var requirements := []

var proof_box : ProofBox


func _init(string : String, new_name:String, module_loader):
	name = new_name
	var current_item = []
	var statement_strings = []
	var definitions = []
	for line in string.split("\n"):
		line = line.strip_edges(false,true)	
		if line.begins_with("@R "):
			_parse_requirement(line.right(3), module_loader)
			current_item = []
		if line.begins_with("@D "):
			if GlobalTypes.TYPING:
				statement_strings.append(_parse_definition(current_item, line.right(3), definitions))
			else:
				_parse_definition(current_item, line.right(3), definitions)
			current_item = []
		elif line.begins_with("@> "):
			statement_strings.append(_parse_statement(current_item, line))
			current_item = []
		elif line.begins_with("@A ") or \
				line.begins_with("@a ") or \
				line.begins_with("@E ") or \
				line.begins_with("@< ") or \
				line.begins_with("@= "):
			current_item.push_front(line)
	
	
	_build_proof_box(definitions)
	
	for statement_string in statement_strings:
		if statement_string != null:
			var expr_item := ExprItemBuilder.from_string(statement_string, proof_box)
			var proof_step = ProofStep.new(expr_item)
			proof_step.justify_with_module_proveable(self)
			proof_steps.append(proof_step)
	
	for proof_step in proof_steps:
		var expr_item:ExprItem = proof_step.get_statement().as_expr_item()
		if expr_item.get_child_count() > 0:
			var argument : ExprItem = expr_item.get_child(expr_item.get_child_count()-1)
			if argument.get_child_count() == 0 and argument.get_type() in get_definitions():
				if Tagger.is_tag(expr_item.abandon_lowest(1)):
					Tagger.put_tag(expr_item.get_child(expr_item.get_child_count()-1).get_type(), Tag.new(expr_item.abandon_lowest(1)))
					proof_step.mark_tag()


func _build_proof_box(definitions:Array) -> void:
	var defs := GlobalTypes.PROOF_BOX.get_definitions().duplicate()
	for requirement in requirements:
		for def in requirement.get_proof_box().get_definitions():
			if not (def in defs):
				defs.append(def) 
	var parent_proof_box = ProofBox.new(defs)
	proof_box = ProofBox.new(definitions, parent_proof_box)


func get_proof_box() -> ProofBox:
	return proof_box


func _parse_requirement(requirement:String, module_loader):
	requirements.append(module_loader.get_module(requirement.strip_edges(true,true)))


func get_proof_steps():
	return proof_steps


func get_definitions() -> Array:
	return proof_box.get_definitions()


func get_requirements() -> Array:
	return requirements


func get_name() -> String:
	return name


func get_definition_dict() -> Dictionary:
	return proof_box.get_


func _parse_definition(qualifiers, def_line:String, definitions:Array):
	var def_name_2 : String = def_line.split(":")[0].strip_edges(true,true)
	if def_line.split(":").size() < 2:
		def_line = def_line + " : ANY"
	var type_info_2 : String = def_line.split(":")[1].strip_edges(true,true)
	definitions.append(ExprItemType.new(def_name_2, type_info_2))
	
	var string = type_info_2 + "(" + def_name_2 + ")"
	for qualifier in qualifiers:
		var qualifier_type = qualifier.left(3)
		var qualifier_payload = qualifier.right(3)
		if qualifier_type == "@A " or qualifier_type == "@a ":
			var def_name : String = qualifier_payload.split(":")[0].strip_edges(true,true)
			var type_info : String = qualifier_payload.split(":")[1].strip_edges(true,true)
			string = "For all(" + def_name + ",=>(" + type_info + "(" + def_name + ")" + "," + string + "))"
	
	return string


func _parse_statement(qualifiers:Array, conclusion) -> String:
	var string = conclusion.right(3)
	for qualifier in qualifiers:
		var qualifier_type = qualifier.left(3)
		var qualifier_payload = qualifier.right(3)
		if qualifier_type == "@A " or qualifier_type == "@a ":
			var def_name : String = qualifier_payload.split(":")[0].strip_edges(true,true)
			var type_info : String = qualifier_payload.split(":")[1].strip_edges(true,true)
			if GlobalTypes.TYPING:
				string = "For all(" + def_name + ",=>(" + type_info + "(" + def_name + ")" + "," + string + "))"
			else:
				string = "For all(" + def_name + "," + string + ")"
		elif qualifier_type == "@< ":
			string = "=>(" + qualifier_payload + "," + string + ")"
		elif qualifier_type == "@= ":
			string = "=(" + qualifier_payload + "," + string + ")"
	return string
