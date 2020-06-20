extends HBoxContainer

signal condition_selected_from_top
signal save_assumption


func _ready():
	$AssumptionBox.connect("assumption_condition_selected", self, "_on_condition_selected")
	$AssumptionBox.connect("assumption_work_with", self, "_on_save_assumption")


func work_with(assumption:Statement):
	$AssumptionBox.display_assumption(assumption)


func _on_condition_selected(statement:Statement, condition_idx:int):
	emit_signal("condition_selected_from_top", statement, condition_idx)


func use_assumption(assumption:Statement):
	$AssumptionBox.use_assumption(assumption)


func _on_save_assumption(assumption:Statement):
	emit_signal("save_assumption", assumption)
