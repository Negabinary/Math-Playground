class_name ModuleItem2

var proof_box : SymmetryBox

func _init():
	pass

func get_next_proof_box():
	return proof_box

func take_type_census(census:TypeCensus) -> TypeCensus:
	assert(false) # virtual
	return null
