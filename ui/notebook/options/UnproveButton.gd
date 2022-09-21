extends Button

onready var selection_handler : SelectionHandler = get_tree().get_nodes_in_group("selection_handler")[0]

func _ready():
	connect("pressed", self, "_on_pressed")
	selection_handler.connect("justification_changed", self, "_on_wpb_changed")
	_on_wpb_changed()

func _on_pressed():
	if selection_handler.get_wpb():
		selection_handler.get_wpb().get_proof_step().justify(MissingJustification.new())

func _on_wpb_changed():
	var justification = selection_handler.get_justification()
	visible = not (justification is MissingJustification or justification is AssumptionJustification or justification is CircularJustification)
