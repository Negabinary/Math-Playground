extends Object
class_name Requirement


var goal : ExprItem
var goal_uid : String
var assumptions : Array #<ExprItem>
var proof_box : ProofBox
var proven : bool


signal proven
signal unproven


func _init(context:ProofBox, goal:ExprItem, definitions=[], assumptions=[]):
	self.goal = goal
	self.goal_uid = goal.get_unique_name()
	self.assumptions = assumptions
	self.proof_box = ProofBox.new(context, definitions, assumptions)
	self.proof_box.connect("proven", self, "_on_proven")
	self.proof_box.connect("unproven", self, "_on_unproven")
	self.proof_box.connect("justified", self, "_on_justified")
	proven = self.proof_box.is_proven(goal)


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
		if proof_box.is_proven(goal) != proven:
			proven = not proven
			emit_signal("proven" if proven else "unproven")
