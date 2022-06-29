extends ScrollContainer

var ASSUMPTION_BOX := load("res://ui/proof/assumption_box/AssumptionBox.tscn")

var goal : ExprItem
var proof_box : ProofBox
var locator : Locator
onready var selection_handler:SelectionHandler = $"../../../..//SelectionHandler"


func _ready():
	selection_handler.connect("locator_changed", self, "_on_goal_item_selected")


func _on_goal_item_selected(expr_locator:Locator):
	if selection_handler.get_wpb():
		set_proof_step(selection_handler.get_selected_goal(), selection_handler.get_wpb().get_inner_proof_box(), expr_locator)
	else:
		_clear_assumptions()


func set_proof_step(goal:ExprItem, proof_box:ProofBox, new_location:Locator=null) -> void:
	if new_location == null:
		new_location = Statement.new(goal).get_conclusion()
	if self.goal != goal and (self.goal == null or not self.goal.compare(goal)) or self.proof_box != proof_box:
		self.goal = goal
		self.proof_box = proof_box
		_update_assumptions()
	locator = new_location


func _clear_assumptions():
	for a in $VBoxContainer.get_children():
		$VBoxContainer.remove_child(a)
		a.queue_free()


func _update_assumptions() -> void:
	_clear_assumptions()
	for assumption in []:
		if ProofStep.new(Requirement.new(assumption[0]), assumption[1]).is_proven():
			save_assumption(assumption[0], assumption[1])


func save_assumption(assumption:ExprItem, assumption_context:ProofBox):
	var assumption_box = ASSUMPTION_BOX.instance()
	$VBoxContainer.add_child(assumption_box)
	assumption_box.initialise(assumption, assumption_context, selection_handler)
	assumption_box.connect("proof_step_created", self, "_on_proof_step_created")


func _on_proof_step_created(x):
	_update_assumptions()
