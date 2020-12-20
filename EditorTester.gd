extends VBoxContainer

func _ready():
	get_child(0).set_expr_item(ExprItemBuilder.from_string("For all(A,For all(B,For all(C,=>(=>(A,B),=>(=>(B,C),=>(A,C))))))", GlobalTypes.PROOF_BOX))
	get_child(1).set_expr_item(null)
