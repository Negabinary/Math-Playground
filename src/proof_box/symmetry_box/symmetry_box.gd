class_name SymmetryBox

var justification_box : AbstractJustificationBox
var parse_box : AbstractParseBox

const justification_children := {} # <AbstractJustificationBox, Dict<String [label], JustificationBox>>


func _init(justification_box:AbstractJustificationBox=RootJustificationBox.new(),
		parse_box:AbstractParseBox=RootParseBox.new()):
	self.justification_box = justification_box
	self.parse_box = parse_box


# CHILDREN ================================================

static func _get_unique_label(definitions:Array, assumptions:Array) -> String:
	var label := str(definitions.size()) + ":"
	for assumption in assumptions:
		label += assumption.get_unique_name(definitions) + ","
	return label


func _get_j_box_for(definitions:=[], assumptions:=[]) -> JustificationBox:
	if not justification_box in justification_children:
		justification_children[justification_box] = {}
	var label := _get_unique_label(definitions, assumptions)
	if not label in justification_children[justification_box]:
		justification_children[justification_box][label] = JustificationBox.new(
			justification_box, assumptions, definitions
		)
	return justification_children[justification_box][label]


func _get_p_box_for(j_box:JustificationBox, definitions:=[]) -> AbstractParseBox:
	if definitions.size() == 0:
		return parse_box
	return DeferredParseBox.new(
		parse_box,
		j_box.get_definitions(),
		definitions
	)


func get_child_extended_with(definitions:=[], assumptions:=[]) -> SymmetryBox:
	if definitions.size() == 0 and assumptions.size() == 0:
		return self
	var next_j_box := _get_j_box_for(definitions, assumptions)
	var next_p_box := _get_p_box_for(next_j_box, definitions)
	return get_script().new(
		next_j_box,
		next_p_box
	)


func convert_requirement(r:Requirement) -> Requirement:
	var old_defs := r.get_definitions()
	if len(old_defs) == 0:
		return r
	var new_defs:Array = _get_j_box_for(r.get_definitions(), r.get_assumptions()).get_definitions()
	if old_defs == new_defs:
		return r
	var map := {}
	for i in old_defs.size():
		map[old_defs[i]] = ExprItem.new(new_defs[i])
	var old_asss := r.get_assumptions()
	var new_asss := []
	for ass in old_asss:
			new_asss.append(ass.deep_replace_types(map))
	return Requirement.new(
		r.get_goal().deep_replace_types(map),
		old_defs,
		new_asss
	)


func get_justification_box() -> AbstractJustificationBox:
	return justification_box


func get_parse_box() -> AbstractParseBox:
	return parse_box
