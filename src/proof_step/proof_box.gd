extends Object
class_name ProofBox


var parent : ProofBox
var definitions : Array # <ExprItemType>
var parse_dict : Dictionary # <String, ExprItemType>


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
