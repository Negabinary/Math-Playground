extends ItemList

func _ready():
#	var AND := ExprItemType.new("and")
#	var dict := {"and":AND}
#
#	var expr1 := ExprItem.from_string("and(=>(A|B)|=>(B|C))", dict)
#	var expr2 := ExprItem.from_string("For all(X|For all(Y|For all(Z|=>(=>(X|=>(X|Z))|=>(and(X|Y)|Z)))))", dict)
#
#	var stat1 := Statement.new(expr1)
#	var stat2 := Statement.new(expr2)
#
#	var loc1 := stat1.get_conclusion()
#	var loc2:UniversalLocator = stat2.get_conditions()[1]
#
#	var matching = Matching.new(loc2, loc1)
#
#	print(matching.is_possible())
#
	
	var expr := ExprItem.from_string("=>(For all(X,For all(Y,=>(=(X,Y),=(Y,X)))),=>(For all(X,For all(Y,For all(Z,=>(=(X,Y),=>(=(Y,Z),=(X,Z)))))),=>(=(S(0),1),=>(=(S(1),2),=>(=(S(2),3),=>(=(S(3),4),=>(For all(X,=(+(0, X),X)),=>(For all(X,For all(Y,=(+(S(X),Y),+(X,(S(Y)))))),=(+(2,2),4)))))))))")
	print(expr.to_string())
	
	#var combination = matching.create_hybrid()
	
	#print(combination.to_string())
