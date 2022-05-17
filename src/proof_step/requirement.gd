extends Object
class_name Requirement


var goal : ExprItem
var goal_uid : String
var assumptions : Array #<ExprItem>
var proven : bool


func _init(goal:ExprItem, definitions=[], assumptions=[]):
	self.goal = goal
	self.goal_uid = goal.get_unique_name()
	self.assumptions = assumptions
	self.proof_box = ProofBox.new(context, definitions, assumptions)
	self.proof_box.connect("proven", self, "_on_proven")
	self.proof_box.connect("unproven", self, "_on_unproven")
	self.proof_box.connect("justified", self, "_on_justified")
	proven = self.proof_box.is_proven(goal)


# GETTERS =================================================

func get_goal() -> ExprItem:
	return goal


func justify(justification) -> void:
	proof_box.add_justification(goal, justification)


func get_proof_box() -> ProofBox:
	return proof_box


func get_or_create_justification(): # -> Justification
	var pbj = proof_box.get_justification_for(self.goal)
	if pbj == null:
		var new_just = MissingJustification.new()
		proof_box.justify(self.goal, new_just)
		return new_just
	else:
		return pbj


# CORRECTNESS =============================================

signal proven
signal unproven
signal justified


func is_proven() -> bool:
	return proven


func _on_proven(uname):
	if uname == self.goal_uid:
		self.proven = true
		emit_signal("proven")


func _on_unproven(uname):
	if uname == self.goal_uid:
		self.proven = false
		emit_signal("unproven")


func _on_justified(uname):
	if uname == goal_uid:
		emit_signal("justified")
		if proof_box.is_proven(goal) != proven:
			proven = not proven
			emit_signal("proven" if proven else "unproven")
