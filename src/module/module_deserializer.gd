class_name ModuleDeserializer

var module_loader

var requirement_strings := []
var item_strings := []

var error : String = ""

var module:MathModule


func eassert(truth:bool, message:String):
	if !truth:
		error = message


func _init(string : String, name : String, module_loader, version = 1):
	self.module = MathModule.new(name)
	self.module_loader = module_loader
	_create_items(string)
	_parse_requirements()
	_parse_items()


func get_module() -> MathModule:
	return module


func _create_items(string : String) -> void:
	var current_item := []
	for line in string.split("\n"):
		var code:String = line.left(3)
		var body:String = line.right(3).strip_edges(true,true)
		match code:
			"@R ":
				requirement_strings.append(line)
			"@D ","@> ","@L ","@X ":
				current_item.push_front(line)
				item_strings.append(current_item)
				current_item = []
			"@A ","@E ","@< ","@= ":
				current_item.push_front(line)


func _parse_requirements() -> void:
	for requirement_string in requirement_strings:
		module.append_requirement(module_loader.get_module(requirement_string.right(3).strip_edges(true,true)))


func _parse_items() -> void:
	for item in item_strings:
		match item[0].left(3):
			"@D ":
				module.append_item(_parse_definition(item, module.get_proof_box()))
			"@> ":
				module.append_item(_parse_statement(item, module.get_proof_box()))
			_:
				eassert(false, "!! Item type not recognised")


func _parse_definition(item : Array, proof_box:ProofBox) -> ModuleItemDefinition:
	var m : String = item.pop_front().right(3)
	if (m.count(":") == 0):
		eassert(item.size() == 0, "Untyped definition shouldn't have any qualifiers")
		return ModuleItemDefinition.new(
			module,
			ExprItemType.new(m.strip_edges())
		)
	else:
		eassert(m.count(":") == 1,"TOO MANY COLONS")
		var identifier := m.split(":")[0].strip_edges()
		var tag_string := m.split(":")[1].strip_edges() + "(" + identifier + ")"
		
		var new_type := ExprItemType.new(identifier)
		
		for line in item:
			var tag_variable
			if line.count(":") == 0:
				tag_variable = line.right(3)
			else:
				eassert(line.split(":")[1].strip_edges() == "TAG", "Tag variable must be a tag")
				tag_variable = line.split(":")[0].right(3).strip_edges()
			tag_string = "For all(" + tag_variable + ",=>(TAG(" + tag_variable + ")," + tag_string + "))"
		
		var tag := ExprItemBuilder.from_string(tag_string, ProofBox.new([new_type], proof_box))
		
		return ModuleItemTaggedDefintion.new(
			module,
			tag,
			new_type
		)


func _parse_statement(item:Array, proof_box:ProofBox) -> ModuleItem:
	var string = item.pop_front().right(3)
	for qualifier in item:
		var qualifier_type = qualifier.left(3)
		var qualifier_payload = qualifier.right(3)
		if qualifier_type == "@A ":
			var def_name : String = qualifier_payload.split(":")[0].strip_edges(true,true)
			if GlobalTypes.TYPING and qualifier_payload.split(":").size() == 2:
				var type_info : String = qualifier_payload.split(":")[1].strip_edges(true,true)
				string = "For all(" + def_name + ",=>(" + type_info + "(" + def_name + ")" + "," + string + "))"
			else:
				string = "For all(" + def_name + "," + string + ")"
		elif qualifier_type == "@< ":
			string = "=>(" + qualifier_payload + "," + string + ")"
		elif qualifier_type == "@= ":
			string = "=(" + qualifier_payload + "," + string + ")"
	return ModuleItemTheorem.new(
		module,
		ExprItemBuilder.from_string(string, proof_box)
	)
