extends VBoxContainer


func serialize() -> void:
	$TextEdit.text = JSON.print(
		generate_dict(), "  "
	)


func deserialize() -> void:
	var backup := generate_dict()
	var parse_result := JSON.parse($TextEdit.text)
	if not parse_result.get_error():
		degenerate_dict(parse_result.result)


func degenerate_dict(dict:Dictionary, path:="user://lib/") -> void:
	var dir = Directory.new()
	if not dir.dir_exists(path):
				dir.make_dir_recursive(path)
	for key in dict:
		if dict[key] is Dictionary:
			degenerate_dict(dict[key], path+key+"/")
		else:
			var f = File.new()
			assert(f.open(path+key, File.WRITE) == OK)
			f.store_string(dict[key])


func generate_dict(path := "user://lib/") -> Dictionary:
	var return_value = {}
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, false)
		var file_name = dir.get_next()
		while file_name  != "":
			if dir.current_is_dir():
				return_value[file_name] = generate_dict(path+file_name+"/")
			else:
				var f = File.new()
				if f.open(path + file_name, File.READ) == 0:
					return_value[file_name] = f.get_as_text()
			file_name = dir.get_next()
	return return_value
