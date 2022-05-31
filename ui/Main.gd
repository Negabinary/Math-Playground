extends VBoxContainer

var file := File.new()
var folder_name = "user://"
onready var ui_notebook : Notebook = $Notebook
onready var ui_save_button : Button = $Controls/FileControls/Save2


func _ready():
	$Controls/FileControls/New.connect("pressed", self, "_new_file_button")
	$Controls/FileControls/Load.connect("pressed", self, "_load_file_button")
	$Controls/FileControls/Save.connect("pressed", self, "_save_as_button")
	ui_save_button.connect("pressed", self, "_save_button")


func _new_file_button():
	ui_save_button.hide()
	ui_notebook.clear()
	file.close()
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
	if file.is_open():
		file.close()
	file.open(path, File.READ_WRITE)
	var parse = JSON.parse(file.get_as_text()).result
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
	if file.is_open():
		file.close()
	file.open(path, File.WRITE_READ)
	print(JSON.print(ui_notebook.serialise()))
	file.store_string(JSON.print(ui_notebook.serialise()))
	file.flush()
	OS.set_window_title(path + " - DiscMath Playground")
	ui_save_button.show()


func _save_button():
	print(JSON.print(ui_notebook.serialise()))
	file.store_string(JSON.print(ui_notebook.serialise()))
	file.flush()
