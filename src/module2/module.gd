class_name Module

"""
I'm intending to use this type only for immutable loaded modules, not for
modules that are currently being edited.
"""

var cells : Array # <Array<ModuleItem>>
var name : String
var bottom_proof_box : ProofBox


func _init(name:String):
	self.name = name
	bottom_proof_box = GlobalTypes.PROOF_BOX


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
				ExprItemBuilder.deserialize(item.expr, proof_box.get_parse_box())
			)
		elif item.kind == "theorem":
			return ModuleItem2Theorem.new(
				proof_box, 
				ExprItemBuilder.deserialize(item.expr, proof_box.get_parse_box()),
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


func get_final_proof_box() -> ProofBox:
	return bottom_proof_box
