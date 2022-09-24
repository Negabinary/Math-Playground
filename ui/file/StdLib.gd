extends Button

func _ready():
	connect("pressed", self, "_on_pressed")

func _on_pressed():
	$AcceptDialog/HTTPRequest.cancel_request()
	$AcceptDialog/HTTPRequest.download_file = "user://modules.txt"
	$AcceptDialog/HTTPRequest.connect("request_completed", self, "_on_list_downloaded")
	$AcceptDialog/HTTPRequest.request("https://raw.githubusercontent.com/Negabinary/Math-Playground-Library/main/std/modules.txt")
	$AcceptDialog.popup_centered()

func _on_list_downloaded(x,y,z,w):
	$AcceptDialog/HTTPRequest.disconnect("request_completed", self, "_on_list_downloaded")
	var f = File.new()
	f.open("user://modules.txt", File.READ)
	$AcceptDialog/Tree.text = f.get_as_text() + "\n"
	var split = $AcceptDialog/Tree.text.split("\n")
	to_download = Array(split)
	to_download.pop_front()
	to_download.pop_back()
	download_all(1,2,3,4)

var to_download : Array

func download_all(x,y,z,w):
	if to_download.empty():
		$AcceptDialog/Tree.text += "Done!" + "\n"
	else:
		$AcceptDialog/HTTPRequest.cancel_request()
		var path : String = to_download.pop_front()
		path = path.split(".").join("/") + ".mml"
		$AcceptDialog/Tree.text += "Downloading std/" + path + "\n"
		$AcceptDialog/HTTPRequest.download_file = "user://save/std/" + path
		var dir = Directory.new()
		dir.make_dir_recursive("user://save/std/" + path)
		dir.remove("user://save/std/" + path)
		$AcceptDialog/HTTPRequest.connect("request_completed", self, "download_all")
		$AcceptDialog/HTTPRequest.request("https://raw.githubusercontent.com/Negabinary/Math-Playground-Library/main/std/" + path)
