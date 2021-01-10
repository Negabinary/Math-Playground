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


# zero_proof_box := GlobalTypes.PROOF_BOX
var one_proof_box := ProofBox.new([],GlobalTypes.PROOF_BOX)   # Contains requirements, GlobalTypes
var two_proof_box := ProofBox.new([],one_proof_box, self)           # Contains new assumptions and definitions


func _init(name:String):
	self.name = name
	_sc()


func _update_one_proof_box() -> void:
	var markings := {}
	var one_definitions = one_proof_box.get_all_definitions()
	var one_assumptions = one_proof_box.get_all_assumptions()
	for requirement in requirements:
		var req_proof_box:ProofBox = requirement.get_proof_box()
		
		# Add missing definitions
		var req_definitions = req_proof_box.get_all_definitions()
		for req_definition in req_definitions:
			if not (req_definition in one_definitions):
				one_proof_box.add_definition(req_definition)
				one_definitions = one_proof_box.get_all_definitions()
			markings[req_definition] = true
		
		# Add missing assumptions
		var req_assumptions = req_proof_box.get_all_assumptions()
		for req_assumption in req_assumptions:
			if not (req_assumption in one_assumptions):
				one_proof_box.add_assumption(req_assumption)
				one_assumptions = one_proof_box.get_all_assumptions()
			markings[req_assumption] = true
	
	#Remove old definitions
	for one_definition in one_proof_box.get_definitions():
		if !markings.has(one_definition):
			one_proof_box.remove_definition(one_definition)
			assert(false) # This hasn't been thought about...
	
	#Remove old assumptions
	for one_assumption in one_proof_box.get_assumptions():
		if !markings.has(one_assumption):
			one_proof_box.remove_assumption(one_assumption)
			assert(false) # This hasn't been thought about...


func append_item(item:ModuleItem):
	items.append(item)
	item.connect("request_delete", self, "_on_item_deleted", [item])
	item.connect("serial_changed", self, "_sc")
	if item.has_as_assumption():
		two_proof_box.add_assumption(item.get_as_assumption())
	if item.get_definition() != null:
		two_proof_box.add_definition(item.get_definition())
	_sc()


func _on_item_deleted(item):
	items.erase(item)
	if item.has_as_assumption():
		two_proof_box.remove_assumption(item.get_as_assumption())
	if item.get_definition() != null:
		two_proof_box.remove_definition(item.get_definition())
	_sc()


func get_item_index(item:ModuleItem):
	return items.find(item)


func get_items() -> Array:
	return items


func append_requirement(requirement:MathModule):
	requirements.append(requirement)
	emit_signal("requirements_updated")
	_update_one_proof_box()
	_sc()


func get_proof(proof_step:ProofStep) -> ProofStep:
	for item in items:
		var x = item.get_as_assumption()
		if x == proof_step:
			return item.get_proof()
	return null


# TODO : make _up_to work
func get_proof_box(_up_to := items.size()) -> ProofBox:
	return two_proof_box


# TODO : make _up_to work
func get_proof_steps(_up_to := items.size()) -> Array:
	return get_proof_box(_up_to).get_assumptions()


func get_definitions(_up_to := items.size()) -> Array:
	return get_proof_box(_up_to).get_definitions()


func get_requirements() -> Array:
	return requirements


func get_name() -> String:
	return name


func _sc():
	emit_signal("serial_changed")
