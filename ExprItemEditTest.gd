extends ExprItemEdit

func _ready():
	set_expr_item(
		ExprItemBuilder.from_string("For all(A,For all(B,For all(C,=>(=>(A,B),=>(=>(B,C),=>(A,C))))))", GlobalTypes.PROOF_BOX)
	)
