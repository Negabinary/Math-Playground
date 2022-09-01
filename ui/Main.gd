extends Control

var path : String = ""
var folder_name = "user://"
onready var ui_notebook : Notebook = $Notebook
onready var ui_save_button : Button = $Controls/FileControls/Save2


func _ready():
	$Controls/FileControls/New.connect("pressed", self, "_new_file_button")
	$Controls/FileControls/Load.connect("pressed", self, "_load_file_button")
	$Controls/FileControls/Save.connect("pressed", self, "_save_as_button")
	var dir = Directory.new()
	if not dir.dir_exists("user://save/"):
		dir.make_dir("user://save/")
	$Controls/FileDialog.current_dir = "user://save/"
	ui_save_button.connect("pressed", self, "_save_button")


func _new_file_button():
	ui_save_button.hide()
	ui_notebook.clear()
	path = ""
	OS.set_window_title("untitled - DiscMath Playground")
	

func _load_file_button():
	$Controls/FileDialog.mode = FileDialog.MODE_OPEN_FILE
	if $Controls/FileDialog.is_connected("file_selected", self, "_confirm_save_file"):
		$Controls/FileDialog.disconnect("file_selected", self, "_confirm_save_file")
	if not $Controls/FileDialog.is_connected("file_selected", self, "_confirm_load_file"):
		$Controls/FileDialog.connect("file_selected", self,"_confirm_load_file")
	$Controls/FileDialog.invalidate()
	$Controls/FileDialog.popup_centered()
	

func _confirm_load_file(path:String):
	# TODO: CHECK FOR UNSAVED WORK
	self.path = path
	var file := File.new()
	file.open(path, File.READ)
	var parse = JSON.parse(file.get_as_text()).result
	file.close()
	ui_notebook.deserialise(parse)
	OS.set_window_title(path + " - DiscMath Playground")
	ui_save_button.show()


func _save_as_button():
	$Controls/FileDialog.mode = FileDialog.MODE_SAVE_FILE
	if $Controls/FileDialog.is_connected("file_selected", self, "_confirm_load_file"):
		$Controls/FileDialog.disconnect("file_selected", self, "_confirm_load_file")
	if not $Controls/FileDialog.is_connected("file_selected", self, "_confirm_save_file"):
		$Controls/FileDialog.connect("file_selected", self,"_confirm_save_file")
	$Controls/FileDialog.invalidate()
	$Controls/FileDialog.popup_centered()


func _confirm_save_file(path:String):
	# TODO: CHECK FOR UNSAVED WORK
	# TODO: CHECK FOR OVERWRITE
	self.path = path
	var file := File.new()
	file.open(path, File.WRITE)
	file.store_string(JSON.print(ui_notebook.serialise()))
	file.close()
	OS.set_window_title(path + " - DiscMath Playground")
	ui_save_button.show()


func _save_button():
	var file := File.new()
	file.open(path, File.WRITE)
	file.store_string(JSON.print(ui_notebook.serialise()))
	file.close()
