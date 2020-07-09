extends HBoxContainer


signal update_selection # Locator


func _init():
	var w2 = ExprItem.from_string("=>(For all(X,=(+(0,X),X)),=>(For all(X,For all(Y,=(+(S(X),Y),+(X,S(Y))))),=>(=(S(0),1),=>(=(S(1),2),=>(=(S(2),3),=>(=(S(3),4),=(+(2,2),4)))))))")
	var expression = Statement.new(w2)
	begin_proof(expression)


func begin_proof(statement:Statement):
	pass
