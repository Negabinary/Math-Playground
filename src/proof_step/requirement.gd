extends Object
class_name Requirement

var goal : ExprItem
var assumptions : Array #<ExprItem>
var proof_box : ProofBox

func _init(context:ProofBox, goal, assumptions=[]):
	self.goal = goal
	self.assumptions = assumptions
	self.proof_box = ProofBox.new(context, )
