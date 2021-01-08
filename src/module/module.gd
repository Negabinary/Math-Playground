extends Object
class_name MathModule


signal requirements_updated
signal serial_changed


var name : String
var description : String  # Unimplemented

var requirements := []

var items := [] # Unimplemented

var proof_steps := []
var proofs := {}


func _init(name:String):
	self.name = name
	_sc()


func append_item(item:ModuleItem):
	items.append(item)
	item.connect("request_delete", self, "_on_item_deleted", [item])
	item.connect("serial_changed", self, "_sc")
	_sc()


func get_item_index(item:ModuleItem):
	return items.find(item)


func get_items() -> Array:
	return items


func append_requirement(requirement:MathModule):
	requirements.append(requirement)
	emit_signal("requirements_updated")
	_sc()


func get_proof(proof_step:ProofStep) -> ProofStep:
	for item in items:
		var x = item.get_as_assumption()
		if x == proof_step:
			return item.get_proof()
	return null


func get_proof_box(up_to := items.size()) -> ProofBox:
	var defs := GlobalTypes.PROOF_BOX.get_definitions().duplicate()
	for requirement in requirements:
		for def in requirement.get_proof_box().get_definitions():
			if not (def in defs):
				defs.append(def)
	var parent_proof_box = ProofBox.new(defs)
	for tag in GlobalTypes.PROOF_BOX.tagging_proof_steps.values():
		parent_proof_box.add_tag(tag)
	for requirement in requirements:
		for type in requirement.get_proof_box().tags:
			for tag in requirement.get_proof_box().tags[type]:
				parent_proof_box.add_tag(tag)
	for module in requirements + [self]:
		for item in module.items:
			if item.has_as_assumption():
				var statement = item.get_as_assumption().get_statement().as_expr_item()
				if statement.get_child_count() != 0 && statement.get_child(statement.get_child_count()-1).get_child_count() == 0:
					parent_proof_box.add_tag(item.get_as_assumption())
	var new_defs := []
	for item_idx in up_to:
		var new_def = items[item_idx].get_definition()
		if new_def != null:
			new_defs.append(new_def)
	return ProofBox.new(new_defs, parent_proof_box)


func get_proof_steps(up_to := items.size()) -> Array:
	var result := []
	for item_idx in up_to:
		var x = items[item_idx].get_as_assumption()
		if x != null:
			result.append(x)
	return result


func get_definitions(up_to := items.size()) -> Array:
	return get_proof_box(up_to).get_definitions()


func get_requirements() -> Array:
	return requirements


func get_name() -> String:
	return name


func _on_item_deleted(item):
	items.erase(item)
	_sc()


func _sc():
	emit_signal("serial_changed")
