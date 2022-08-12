class_name SymmetryBox

var children := {} # <String [requirement label], ExprItem>
var children_defs := {} # <String [requirement label], Array<ExprItemType>>
var justification_box : AbstractJustificationBox


func _init(justification_box:AbstractJustificationBox=RootJustificationBox.new()):
	self.justification_box = justification_box


# CHILDREN ================================================

static func _get_unique_label(definitions:Array, assumptions:Array) -> String:
	var label := str(definitions.size()) + ":"
	for assumption in assumptions:
		label += assumption.get_unique_name(definitions) + ";"
	return label


func get_child_extended_with(definitions:=[], assumptions:=[]) -> SymmetryBox:
	if definitions.size() == 0 and assumptions.size() == 0:
		return self
	var label := _get_unique_label(definitions, assumptions)
	if not (label in children):
		children[label] = get_script().new(
			JustificationBox.new(
				get_justification_box(), definitions, assumptions
			)
		)
		children_defs[label] = definitions
	return children[label]


func convert_requirement(r:Requirement) -> Requirement:
	var old_defs := r.get_definitions()
	var old_asss := r.get_assumptions()
	var label := _get_unique_label(old_defs, old_asss)
	if label in children_defs:
		var new_defs:Array = children_defs[label]
		assert(old_defs.size() == new_defs.size())
		var map := {}
		for i in old_defs.size():
			map[old_defs[i]] = ExprItem.new(new_defs[i])
		var new_asss := []
		for ass in old_asss:
			new_asss.append(ass.deep_replace_types(map))
		return Requirement.new(
			r.get_goal().deep_replace_types(map),
			new_defs,
			new_asss
		)
	else:
		return r


func get_justification_box() -> AbstractJustificationBox:
	return justification_box


func get_parse_box() -> AbstractParseBox:
	return justification_box.get_parse_box()
