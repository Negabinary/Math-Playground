class_name Module

"""
I'm intending to use this type only for immutable loaded modules, not for
modules that are currently being edited.
"""

var cells : Array # <Array<ModuleItem>>
var name : String
var bottom_proof_box : SymmetryBox


func _init(name:String):
	self.name = name
	bottom_proof_box = GlobalTypes.get_root_symmetry()


func get_name() -> String:
	return name


func get_all_items() -> Array:
	var items := []
	for cell in cells:
		items.append_array(cell)
	return items


func get_all_definitions(recursive:bool) -> Array: #<EIT>
	var all_definitions = []
	for cell in cells:
		for item in cell:
			all_definitions.append_array(item.get_all_definitions(recursive))
	return all_definitions


func get_all_assumptions(recursive:bool) -> Array: #<EI>
	var all_assumptions = []
	for cell in cells:
		for item in cell:
			all_assumptions.append_array(item.get_all_assumptions(recursive))
	return all_assumptions


func get_all_theorems(recursive:bool) -> Array: #<EI>
	var all_theorems = []
	for cell in cells:
		for item in cell:
			all_theorems.append_array(item.get_all_theorems(recursive))
	return all_theorems


func get_all_imports(recursive:bool) -> Array: #<String>
	var all_imports = []
	for cell in cells:
		for item in cell:
			all_imports.append_array(item.get_all_imports(recursive))
	return all_imports


func deserialize_cell(cell_json:Dictionary) -> void:
	var new_cell := []
	if cell_json.compiled:
		for item in cell_json.items:
			var new_item := deserialise_item(item, bottom_proof_box)
			bottom_proof_box = new_item.get_next_proof_box()
			new_cell.append(new_item)
	cells.append(new_cell)


func get_as_statement(name:ExprItemType) -> ExprItem:
	var all_definitions := get_all_definitions(false)
	var all_theorems := get_all_assumptions(false)
	var all_assumptions := get_all_theorems(false)
	var result := ExprItem.new(GlobalTypes.EOF)
	for i in range(len(all_theorems)-1, -1, -1):
		result = ExprItem.new(GlobalTypes.AND,[
			all_theorems[i],
			result
		])
	for ass in reverse(all_assumptions):
		result = ExprItem.new(GlobalTypes.IMPLIES,[
			ass,
			result
		])
	var def_eis := []
	for def in all_definitions:
		def_eis.append(ExprItem.new(def))
	result = ExprItem.new(GlobalTypes.EQUALITY,[
		ExprItem.new(name, def_eis),
		result
	])
	print(def_eis)
	for def_ei in reverse(def_eis):
		result = ExprItem.new(GlobalTypes.FORALL,[
			def_ei,
			result
		])
	return result


static func reverse(list):
	var result := []
	for i in list:
		result.push_front(i)
	return result


# A lot of this code is duplicated. This is the version used for imports
static func deserialise_item(item, proof_box:SymmetryBox) -> ModuleItem2:
		var module_item : ModuleItem2
		if item.kind == "definition":
			return ModuleItem2Definition.new(
				proof_box, 
				ExprItemType.new(item.type)
			)
		elif item.kind == "assumption":
			return ModuleItem2Assumption.new(
				proof_box, 
				ExprItemBuilder.deserialize(item.expr, proof_box.get_parse_box())
			)
		elif item.kind == "theorem":
			return ModuleItem2Assumption.new(
				proof_box, 
				ExprItemBuilder.deserialize(item.expr, proof_box.get_parse_box())
			)
		elif item.kind == "import":
			return ModuleItem2Import.new(
				proof_box,
				item.module,
				item.get("namespace", false)
			)
		elif item.kind == "implement":
			return ModuleItem2Implement.new(
				proof_box,
				item.module,
				ExprItemType.new(item.new_name)
			)
		else:
			assert(false)
			return null


func get_final_proof_box() -> SymmetryBox:
	return bottom_proof_box
