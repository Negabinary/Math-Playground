extends Object
class_name ProofBox


var parent : ProofBox
var definitions : Array # <ExprItemType>
var parse_dict : Dictionary # <String, ExprItemType>
var tags : Dictionary
var tagging_proof_steps : Dictionary #<ExprItemTagHelper,ProofStep>


func _init(definitions:Array, parent:ProofBox = null): #<ExprItemType,String>
	self.parent = parent
	self.definitions = definitions
	update_parse_dict()
	for definition in definitions:
		definition.connect("renamed", self, "update_parse_dict")


func update_parse_dict():
	for definition in definitions:
		parse_dict[definition.get_identifier()] = definition


func parse(string:String) -> ExprItemType:
	if string in parse_dict:
		return parse_dict[string]
	elif parent != null:
		return parent.parse(string)
	else:
		return null


func get_full_parse_dict() -> Dictionary:
	var fpd = parent.get_full_parse_dict()
	for string in parse_dict:
		fpd[string] = parse_dict[string]
	return fpd


func get_definitions() -> Array:
	return definitions


func get_all_types() -> Array:
	if parent == null:
		return definitions
	else:
		return definitions + parent.get_all_types()


func add_tag(tagging) -> void: # tagging:ProofStep
	var tag_helper := ExprItemTagHelper.new(tagging.get_statement().as_expr_item())
	var type := tag_helper.get_tagged_type()
	if tags.has(type):
		tags[type] += [tag_helper]
	else:
		tags[type] = [tag_helper]
	tagging_proof_steps[tag_helper] = tagging
#	assert (find_tag(ExprItem.new(type), tagging.get_statement().as_expr_item()) != null)


func find_tag(expr:ExprItem, tagging_check:ExprItem): # -> ProofStep
	if expr.get_type() == GlobalTypes.F_DEF:
		print(str(expr, " : ", tagging_check))
	if tags.has(expr.get_type()):
		for type_taging in tags[expr.get_type()]:
			if expr.get_child_count() == 0:
				print("'soup")
				print("> Normal Match")
				return tagging_proof_steps[type_taging]
			else:
				print("'sup")
				print(type_taging.get_return_tag(expr.get_child_count()-1))
				if type_taging.get_return_tag(expr.get_child_count()-1).get_expr_item().compare(tagging_check.abandon_lowest(1)):
					print("> Application Match")
					#return tagging_proof_steps[type_taging]
	if parent != null:
		return parent.find_tag(expr, tagging_check)
	else:
		return null


func is_tag(expr:ExprItem):
	return find_tag(expr, ExprItem.new(GlobalTypes.TAG,[expr]))
