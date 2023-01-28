class_name Refinable


var missing_types := [] # ExprItemType
var unrefined_provable : Provable


func _init(provable:Provable, missing_types:Array): #<ExprItemType>
	self.missing_types = missing_types
	self.unrefined_provable = provable


func get_missing_types() -> Array: #<ExprItemType>
	return missing_types


func refine(new_exprs:Array) -> Provable: #<ExprItem>
	var matching := {}
	assert(len(new_exprs) == len(missing_types))
	for i in len(missing_types):
		matching[missing_types[i]] = new_exprs[i]
	return unrefined_provable.deep_replace_types(matching)
