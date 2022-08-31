extends ScrollContainer

var ASSUMPTION_BOX := load("res://ui/proof/assumption_box/AssumptionBox.tscn")

var goal : ExprItem
var proof_box : SymmetryBox
var locator : Locator
onready var selection_handler:SelectionHandler = $"../../../..//SelectionHandler"
var request_map := {} #<StarButton, AssumptionBox>


func _ready():
	selection_handler.assumption_pane = self


func save_assumption(assumption:ExprItem, assumption_context:SymmetryBox, requester:StarButton=null):
	var assumption_box = ASSUMPTION_BOX.instance()
	request_map[requester] = assumption_box
	$VBoxContainer.add_child(assumption_box)
	assumption_box.initialise(assumption, assumption_context, selection_handler)
	requester.connect("tree_exiting", self, "remove_assumption", [requester])


func remove_assumption(requester:StarButton=null):
	var to_remove = request_map.get(requester,null)
	if to_remove:
		request_map.erase(requester)
		$VBoxContainer.remove_child(to_remove)
		to_remove.queue_free()
