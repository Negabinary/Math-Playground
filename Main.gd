extends Control

onready var ui_assumptions := $VSplitContainer/Proof/Context/VBoxContainer/Assumptions
onready var ui_goals := $VSplitContainer/Proof/Goals
onready var ui_proof_steps := $VSplitContainer/Proof/ProofSteps
onready var ui_written_proof := $VSplitContainer/Proof/ColorRect/ScrollContainer/WrittenProof
onready var ui_modules := $VSplitContainer/Modules
#onready var ui_buttons := $ColorRect/Buttons

var root_ps : ProofStep

func _set_up() -> void:
	var w2 = ExprItemBuilder.from_string("For all(A,For all(B,For all(C,=>(=>(A,B),=>(=>(B,C),=>(A,C))))))", GlobalTypes.PROOF_BOX)
#	w2 = ExprItem.from_string("=>(=>(A,=>(B,C)),=>(=>(A,B),C))")
#	w2 = ExprItem.from_string("=>(=>(=>(A,B),C),=>(A,=>(B,C)))")
#	w2 = ExprItem.from_string("=>(=(A,B),=>(=>(P(A),P(C)),=>(P(B),P(C))))")
#	w2 = ExprItem.from_string("=>(=>(A,=>(B,C)),=>(=>(A,=>(C,D)),=>(A,=>(B,D))))")
#	w2 = ExprItem.from_string("For all(X,<=>(Bool(X),=>(¬(=(X,True)),(X,False))))")
#	w2 = ExprItem.from_string("=>(For all(X,=>(Bool(X),=>(¬(=(X,True)),=(X,False)))),=>(For all(X,=>(=>(¬(=(X,True)),=(X,False)),Bool(X))),Bool(True)))")
#	w2 = ExprItem.from_string("=>(For all(Z, =(Z,Z)),=>(=(2,S(S(0))),=>(=(4,S(S(S(S(0))))),=>(For all(X,=(+(X,0),X)),=>(For all(X,For all(Y,=(+(X,S(Y)),S(+(X,Y))))),=(+(2,2),4))))))")
#	w2 = ExprItem.from_string("=>(Even(0),=>(Odd(S(0)),=>(=(Double(0),0),=>(Forall(X,=(Double(S(X)),S(S(Double(X))))),=>(Even(A),Even(Double(A)))))))")
#	w2 = ExprItem.from_string("=>(For all(X,=>(For all(Y, ¬(=(X,S(Y)))),=(X,0))),=>(For all(X,=(+(X,0),X)),=>(For all(X,For all(Y,=(+(X,S(Y)),S(+(X,Y))))),For all(X,=(+(0,X),X)))))")
#	w2 = ExprItem.from_string("=>(=>(Light(Green),=>(Road(Empty),Go)),=>(=>(¬(Light(Red)),=>(¬(Light(Yellow)),Light(Green))),=>(¬(Light(Red)),=>(¬(Light(Yellow)),=>(Road(Empty),Go)))))")
#	w2 = ExprItem.from_string("For all(X,=>(Exists(X),=>(For all(Y,¬(Explains(Y,X))),Necessary(X))))")
#	w2 = ExprItem.from_string("=>(For all(X,=>(Exists(X),=>(For all(Y,¬(Explains(Y,X))),Necessary(X)))),=>(¬(Necessary(The Universe)),=>(For all(Y,=>(Explains(Y,The Universe),¬(In(Y,The Universe)))),=>(For all(Y,=>(¬(In(Y,The Universe)),=>(¬(Abstract(Y)),=(Y,God)))),=>(For all(Y,=>(Explains(Y,The Universe),¬(Abstract(Y)))),=>(Exists(The Universe),Explains(God,The Universe)))))))")
#	w2 = ExprItem.from_string("=>(For all(X,=>(Exists(X),=>(¬(Necessary(X)),Explains(Z,X)))),=>(¬(Necessary(The Universe)),=>(For all(Y,=>(Explains(Y,The Universe),¬(In(Y,The Universe)))),=>(For all(Y,=>(¬(In(Y,The Universe)),=>(¬(Abstract(Y)),=(Y,God)))),=>(For all(Y,=>(Explains(Y,The Universe),¬(Abstract(Y)))),=>(Exists(The Universe),Explains(God,The Universe)))))))")
#	w2 = ExprItem.from_string("=>(For all(X,=>(Exists(X),=>(¬(Necessary(X)),For some(Z,Explains(Z,X))))),=>(¬(Necessary(The Universe)),=>(For all(Y,=>(Explains(Y,The Universe),¬(In(Y,The Universe)))),=>(For all(Y,=>(¬(In(Y,The Universe)),=>(¬(Abstract(Y)),=(Y,God)))),=>(For all(Y,=>(Explains(Y,The Universe),¬(Abstract(Y)))),=>(Exists(The Universe),Explains(God,The Universe)))))))")
#	w2 = ExprItem.from_string("=>(=>(For some(Z,Q(Z)),Q(X)),=>(Q(Y),Q(X))))")
#	w2 = ExprItem.from_string("=>(For some(Z,Q(Z)),=>(For all(Y,=>(Q(Y),P)),P))")
#	w2 = ExprItem.from_string("=>(=>(¬(God),¬(Morals)),=>(Morals,God))")
	
	
	root_ps = ProofStep.new(w2)
	#ui_proof_steps.display_proof(root_ps)
	ui_written_proof.display_proof(root_ps)


func _ready():
	_set_up()
	ui_proof_steps.connect("proof_step_selected", self, "_on_proof_step_selected")
	ui_goals.connect("expr_item_selected", self, "_on_goal_item_selected")
	ui_modules.initialise($SelectionHandler)
	$SelectionHandler.connect("proof_step_changed", self, "_on_proof_step_selected")
	$SelectionHandler.connect("locator_changed", self, "_on_goal_item_selected")
	$SelectionHandler.connect("proof_changed", self, "_set_proof")

func _on_proof_step_selected(proof_step:ProofStep):
	ui_goals.show_expression(Statement.new(proof_step.get_statement().as_expr_item()))
	ui_assumptions.set_proof_step(proof_step)


func _on_goal_item_selected(expr_locator:Locator):
	ui_assumptions.set_locator(expr_locator)


func _set_proof(proof_step:ProofStep):
	ui_written_proof.display_proof(proof_step)
	_on_proof_step_selected(proof_step)
