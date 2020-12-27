extends Button


func _ready():
	connect("pressed", self, "_test")


func can_drop_data(position, data):
	return true


func drop_data(position, data):
	print(data)


func _test():
	var f := File.new()
	f.open("user://test.dat", File.WRITE)
	f.store_line("Test")
	f.store_line("Test2\nTest3")
	f.close()
	
	f = File.new()
	f.open("C:/Users/Matt/Unsafe/test.dat", File.WRITE)
	f.store_line("Test")
	f.store_line("Test2\nTest3")
	f.close()
