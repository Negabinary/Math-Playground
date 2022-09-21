class_name ProofStep

signal child_proven

var requirement : Requirement # final
var context :  SymmetryBox # final
var parent : ProofStep # final


# FINAL STUFF =============================================

func _init(requirement:Requirement, context:SymmetryBox, parent:ProofStep=null):
	self.requirement = requirement
	self.context = context.get_child_extended_with(
		requirement.get_definitions(),
		requirement.get_assumptions()
	)
	self.parent = parent
	_connect_justification()
	_connect_dependencies()
	_connect_proof_status()


func get_inner_proof_box() -> SymmetryBox:
	return context


func get_goal() -> ExprItem:
	return requirement.get_goal()


func get_requirement() -> Requirement:
	return requirement


# JUSTIFICATION ===========================================


signal justification_type_changed
var justification : Justification


func get_justification() -> Justification:
	if justification == null:
		_update_justification()
	return justification


func _connect_justification():
	_update_justification()
	self.context.get_justification_box().connect("updated", self,"_on_justifified")
	if justification is MissingJustification:
		context.get_justification_box().connect("assumption_added", self, "_on_assumption_added")
	elif context.get_justification_box().is_connected("assumption_added", self, "_on_assumption_added"):
		context.get_justification_box().disconnect("assumption_added", self, "_on_assumption_added")
	if justification is AssumptionJustification:
		context.get_justification_box().connect("assumption_removed", self, "_on_assumption_removed")
	elif context.get_justification_box().is_connected("assumption_removed", self, "_on_assumption_removed"):
		context.get_justification_box().disconnect("assumption_removed", self, "_on_assumption_removed")


func _on_justifified(uid):
	if uid == requirement.get_goal().get_unique_name():
		_update_justification()


func _on_assumption_added(assumption:ExprItem):
	if assumption.compare(requirement.get_goal()):
		_update_justification()


func _on_assumption_removed(assumption:ExprItem):
	if assumption.compare(requirement.get_goal()):
		_update_justification()


func _update_justification():
	justification = context.get_justification_box().get_justification_or_missing(requirement.get_goal())
	if parent != null:
		var wuj := parent._who_uses_justification(justification)
		if wuj:
			if wuj.get_inner_proof_box().get_justification_box() == context.get_justification_box():
				justification = CircularJustification.new()
			else:
				justification = MissingJustification.new()
				context.get_justification_box().set_justification(requirement.get_goal(), justification)
	emit_signal("justification_type_changed")
	_connect_justification_properties()


func _who_uses_justification(j:Justification) -> ProofStep:
	if get_justification() == j:
		return self
	elif parent == null:
		return null
	else:
		return parent._who_uses_justification(j)


func justify(new_justification:Justification) -> void:
	context.get_justification_box().set_justification(requirement.get_goal(), new_justification)


# JUSTIFICATION PROPERTIES ===============================

signal justification_properties_changed

func _connect_justification_properties():
	if not justification.is_connected("updated", self, "emit_signal"):
		justification.connect("updated", self, "emit_signal", ["justification_properties_changed"])
	emit_signal("justification_properties_changed")


# DEPENDENCIES ============================================

signal dependencies_changed
var dependencies : Array

func _connect_dependencies():
	connect("justification_properties_changed", self, "_update_dependencies")
	_update_dependencies()


func _update_dependencies():
	var ureqs = get_justification().get_requirements_for(
		requirement.get_goal(), 
		context.get_parse_box()
	)
	var reqs = []
	if ureqs != null:
		for ureq in ureqs:
			reqs.append(context.convert_requirement(ureq))
	var proof_steps := []
	for req in reqs:
		proof_steps.append(get_script().new(req, context, self))
	for proof_step in proof_steps:
		proof_step.connect("child_proven", self, "emit_signal", ["child_proven"])
	dependencies = proof_steps
	emit_signal("dependencies_changed")


func get_dependencies() -> Array:
	return dependencies


# PROOF STATUS ============================================

signal proof_status
var proven : bool

func _connect_proof_status():
#	if not is_connected("justification_properties_changed", self, "_update_proof_status"): # reduntant
#		connect("justification_properties_changed", self, "_update_proof_status")
	for dependency in get_dependencies():
		dependency.connect("proof_status", self, "_update_proof_status")
	if not is_connected("dependencies_changed", self, "_connect_proof_status"):
		connect("dependencies_changed", self, "_connect_proof_status")
	_update_proof_status()


func _update_proof_status() -> void:
	var new_value : bool
	if is_justification_valid():
		new_value = true
		for dependency in get_dependencies():
			if not dependency.is_proven():
				new_value = false
	else:
		new_value = false
	if new_value != proven:
		proven = new_value
		emit_signal("proof_status")


func is_justification_valid() -> bool:
	return get_justification().get_requirements_for(
		requirement.get_goal(), 
		context.get_parse_box()
	) != null


func is_proven():
	return proven


func is_proven_except(idx:int):
	if is_justification_valid():
		var deps := get_dependencies()
		for dep in deps.size():
			if dep != idx:
				if not deps[dep].is_proven():
					return false
		return true
	else:
		return false


# SAVE / LOAD =============================================


func serialize_proof() -> Dictionary:
	var dependencies := []
	for dep in get_dependencies():
		dependencies.append(dep.serialize_proof())
	return {
		requirement=requirement.serialize(context.get_parse_box()),
		justification=get_justification().serialize(context.get_parse_box()),
		dependencies=dependencies
	}

static func deserialize_proof(script:Script, dictionary, context:SymmetryBox, version) -> void:
	var r = Requirement.deserialize(Requirement, dictionary.requirement, context)
	var cr = context.convert_requirement(r)
	var ipb = context.get_child_extended_with(
		cr.get_definitions(),
		cr.get_assumptions()
	)
	var j := JustificationBuilder.deserialize(
			dictionary.justification, 
			ipb.get_parse_box(),
			version
		)
	if j:
		ipb.get_justification_box().set_justification(cr.get_goal(), j)
	for dependency in dictionary.dependencies:
		deserialize_proof(script, dependency, ipb, version)
