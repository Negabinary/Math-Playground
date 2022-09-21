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


func deserialize_cell(cell_json:Dictionary) -> void:
	var new_cell := []
	for item in cell_json.items:
		var new_item := deserialise_item(item, bottom_proof_box)
		bottom_proof_box = new_item.get_next_proof_box()
		new_cell.append(new_item)
	cells.append(new_cell)


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
		else:
			assert(false)
			return null


func get_final_proof_box() -> SymmetryBox:
	return bottom_proof_box
