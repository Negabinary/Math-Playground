class_name ModuleItem2

var proof_box : SymmetryBox

func _init():
	pass

func get_next_proof_box():
	return proof_box

func take_type_census(census:TypeCensus) -> TypeCensus:
	assert(false) # virtual
	return null


func get_all_definitions(recursive:bool) -> Array: #<EIT>
	return []


func get_all_assumptions(recursive:bool) -> Array: #<EI>
	return []


func get_all_theorems(recursive:bool) -> Array: #<EI>
	return []


func get_all_imports(recursive:bool) -> Array: #<String>
	return []
