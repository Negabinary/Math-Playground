class_name ProofStep


var requirement : Requirement # final
var context :  SymmetryBox # final
var parent : ProofStep # final


signal justification_type_changed
var justification : Justification
signal justification_properties_changed
var justification_valid : bool
signal dependencies_changed
var dependencies : Array
signal active_dependency_changed
var active_dependency := 0
signal proof_status
var proven : bool


# INIT ====================================================

func _init(requirement:Requirement, outer_context:SymmetryBox, parent:ProofStep=null):
	self.requirement = requirement
	self.context = outer_context.get_child_extended_with(
		requirement.get_definitions(),
		requirement.get_assumptions()
	)
	self.parent = parent
	
	self.justification = _find_justification()
	var jreq = justification.get_requirements_for(
		requirement.get_goal(), 
		self.context.get_parse_box()
	)
	self.justification_valid = jreq != null
	self.dependencies = _find_dependencies(jreq)
	self.active_dependency = _choose_active_dependency()
	self.proven = _find_proof_status()
	
	self.context.get_justification_box().connect("assumption_added", self, "_on_assumption_added")
	self.context.get_justification_box().connect("assumption_removed", self, "_on_assumption_removed")
	self.context.get_justification_box().connect("updated", self,"_on_justifified")
	self.justification.connect("updated", self, "_on_justification_updated")
	for dependency in get_dependencies():
		dependency.connect("proof_status", self, "_update_proof_status")


# CALCULATORS =============================================

func _find_justification() -> Justification:
	var j = context.get_justification_box().get_justification_or_missing(requirement.get_goal())
	if parent != null:
		var wuj := parent._who_uses_justification(j)
		if wuj:
			if wuj.get_inner_proof_box().get_justification_box() == context.get_justification_box():
				j = CircularJustification.new()
			else:
				j = MissingJustification.new()
				context.get_justification_box().set_justification(requirement.get_goal(), j)
	return j


func _who_uses_justification(j:Justification) -> ProofStep:
	if get_justification() == j:
		return self
	elif parent == null:
		return null
	else:
		return parent._who_uses_justification(j)


func _find_dependencies(ureqs) -> Array:
	var reqs = []
	if ureqs != null:
		for ureq in ureqs:
			reqs.append(context.convert_requirement(ureq))
	var proof_steps := []
	for req in reqs:
		proof_steps.append(get_script().new(req, context, self))
	return proof_steps


func _choose_active_dependency():
	for i in len(dependencies):
		if not dependencies[i].is_proven():
			return i
	return 0


func _find_proof_status() -> bool:
	var new_value : bool
	if is_justification_valid():
		new_value = true
		for dependency in get_dependencies():
			if not dependency.is_proven():
				new_value = false
	else:
		new_value = false
	return new_value


# UPDATES =================================================

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
	self.justification.disconnect("updated", self, "_on_justification_updated")
	for dependency in dependencies:
		dependency.disconnect("proof_status", self, "_update_proof_status")
	self.justification = _find_justification()
	var jreq = justification.get_requirements_for(
		requirement.get_goal(), 
		self.context.get_parse_box()
	)
	self.justification_valid = jreq != null
	self.dependencies = _find_dependencies(jreq)
	self.active_dependency = _choose_active_dependency()
	var old_proven := self.proven
	self.proven = _find_proof_status()
	self.justification.connect("updated", self, "_on_justification_updated")
	for dependency in dependencies:
		dependency.connect("proof_status", self, "_update_proof_status")
	emit_signal("justification_type_changed")
	emit_signal("justification_properties_changed")
	emit_signal("dependencies_changed")
	emit_signal("active_dependency_changed")
	if old_proven != proven:
		emit_signal("proof_status")


func _on_justification_updated():
	for dependency in dependencies:
		dependency.disconnect("proof_status", self, "_update_proof_status")
	var jreq = justification.get_requirements_for(
		requirement.get_goal(), 
		self.context.get_parse_box()
	)
	self.justification_valid = jreq != null
	self.dependencies = _find_dependencies(jreq)
	self.active_dependency = _choose_active_dependency()
	var old_proven := self.proven
	self.proven = _find_proof_status()
	for dependency in dependencies:
		dependency.connect("proof_status", self, "_update_proof_status")
	emit_signal("justification_properties_changed")
	emit_signal("dependencies_changed")
	emit_signal("active_dependency_changed")
	if old_proven != proven:
		emit_signal("proof_status")


func _on_dependency_proved():
	var old_proven := self.proven
	self.proven = _find_proof_status()
	if old_proven != proven:
		emit_signal("proof_status")


# GETTERS =================================================

func get_inner_proof_box() -> SymmetryBox:
	return context


func get_goal() -> ExprItem:
	return requirement.get_goal()


func get_requirement() -> Requirement:
	return requirement


func get_parent() -> ProofStep:
	return parent


func get_justification() -> Justification:
	return justification


func get_active_dependency() -> int:
	return active_dependency


func get_dependencies() -> Array:
	return dependencies


func is_justification_valid() -> bool:
	return justification_valid


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


# SETTERS =================================================

func set_active_dependency(value:int):
	active_dependency = value
	emit_signal("active_dependency_changed")


func justify(new_justification:Justification) -> void:
	context.get_justification_box().set_justification(requirement.get_goal(), new_justification)



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


# TYPE CENSUS =============================================

func take_type_census(census:TypeCensus) -> TypeCensus:
	var new_census = census if requirement.get_definitions().size() == 0 else TypeCensus.new()
	for dep in get_dependencies():
		dep.take_type_census(new_census)
	get_justification().take_type_census(new_census)
	if requirement.get_definitions().size() > 0:
		for def in get_inner_proof_box().get_parse_box().get_definitions():
			new_census.remove_entry(def)
		census.merge(new_census)
	return census
