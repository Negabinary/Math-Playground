extends ConfirmationDialog

const REPLACEMENT_SCENE = preload("res://ui/proof/assumptions/buttons/refining/Replacement.tscn")
var refinable : Refinable
var context : SymmetryBox


func _init():
	connect("confirmed", self, "_on_confirmed")


func request_types(refinable:Refinable, context:SymmetryBox):
	self.refinable = refinable
	self.context = context
	for child in $"%Replacements".get_children():
		$"%Replacements".remove_child(child)
	for type in refinable.get_missing_types():
		var rep := REPLACEMENT_SCENE.instance()
		rep.init(context.get_parse_box(), type)
		rep.connect("updated", self, "_on_child_update")
		$"%Replacements".add_child(rep)
	_on_child_update()
	popup_centered()


func _is_valid():
	for c in $"%Replacements".get_children():
		if not c.is_valid():
			return false
	return true


func _on_child_update():
	get_ok().disabled = not _is_valid()


func _on_confirmed():
	var new_eis = []
	for c in $"%Replacements".get_children():
		new_eis.append(c.get_expr_item())
	var provable := refinable.refine(new_eis)
	provable.apply_proof(context)
