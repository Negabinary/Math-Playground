extends Button

func _ready():
	connect("pressed", $Book, "open_book")
