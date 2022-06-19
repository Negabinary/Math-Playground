class_name ProofStep

signal justification_type_changed
signal justification_properties_changed
signal dependencies_changed
signal child_proven

var requirement : Requirement # final
var context : ProofBox # final


func _init(requirement:Requirement, context:ProofBox):
	self.requirement = requirement
	self.context = context.get_child_extended_with(
		requirement.get_definitions(),
		requirement.get_assumptions()
	)
	self.context.connect("justified", self,"_on_justifified")
	get_justification().connect("updated", self, "_on_justification_updated")
	get_justification().connect("request_replace", self, "justify")


func justify(new_justification:Justification) -> void:
	context.add_justification(requirement.get_goal(), new_justification)


func _on_justifified(uid):
	if uid == context.get_uid(requirement.get_goal()):
		emit_signal("justification_type_changed")
		# I haven't disconnected the previous one - I don't think that will cause problems?
		get_justification().connect("updated", self, "_on_justification_updated")
		get_justification().connect("request_replace", self, "justify")
		emit_signal("dependencies_changed")
		emit_signal("child_proven")


func _on_justification_updated():
	emit_signal("justification_properties_changed")
	emit_signal("dependencies_changed")
	emit_signal("child_proven")


func get_justification():
	return context.get_justification_or_missing_for(requirement.get_goal())


func get_inner_proof_box() -> ProofBox:
	return context


func get_goal() -> ExprItem:
	return requirement.get_goal()


func get_requirement() -> Requirement:
	return requirement


func get_dependencies() -> Array:
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
		proof_steps.append(get_script().new(req, context))
	for proof_step in proof_steps:
		proof_step.connect("child_proven", self, "emit_signal", ["child_proven"])
	return proof_steps


func is_justification_valid() -> bool:
	return get_justification().get_requirements_for(
		requirement.get_goal(), 
		context.get_parse_box()
	) != null


func is_proven():
	if is_justification_valid():
		for dependency in get_dependencies():
			if not dependency.is_proven():
				return false
		return true
	else:
		return false


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


func serialize_proof() -> Dictionary:
	var dependencies := []
	for dep in get_dependencies():
		dependencies.append(dep.serialize_proof())
	return {
		requirement=requirement.serialize(),
		justification=get_justification().serialize(),
		dependencies=dependencies
	}

static func deserialize_proof(script:Script, dictionary, context:ProofBox, version) -> ProofStep:
	var n:ProofStep = script.new(
		Requirement.deserialize(Requirement, dictionary.requirement, context.get_parse_box()),
		context
	)
	if not n.is_proven():
		var j := JustificationBuilder.deserialize(
			dictionary.justification, 
			n.get_inner_proof_box().get_parse_box(),
			version
		)
		if j:
			n.justify(j)
	for dependency in dictionary.dependencies:
		deserialize_proof(script, dependency, n.get_inner_proof_box(), version)
	return n
