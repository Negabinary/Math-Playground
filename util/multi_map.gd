class_name MultiMap

var mm := {}


func append_to(index, value):
	if not index in mm:
		mm[index] = []
	mm[index].append(value)


func remove_from(index, value) -> void:
	mm.get(index,[]).erase(value)


func remove_all(index, value) -> void:
	var arr:Array = mm.get(index,[])
	while value in arr:
		arr.erase(value)


func get_all(index):
	return mm.get(index,[])


func keys():
	return mm.keys()


func count(index) -> int:
	return mm.get(index,[]).size()


func clear(index) -> void:
	mm.erase(index)


func get_all_values() -> Array:
	var all_values := []
	for k in mm.values():
		all_values.append_array(k)
	return all_values
