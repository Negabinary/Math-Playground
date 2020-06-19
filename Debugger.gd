extends ItemList

func _ready():
	var AND := ExprItemType.new("and")
	var dict := {"and":AND}
	
	var expr1 := ExprItem.from_string("and(=>(A|B)|=>(B|C))", dict)
	var expr2 := ExprItem.from_string("For all(X|For all(Y|For all(Z|=>(=>(X|=>(X|Z))|=>(and(X|Y)|Z)))))", dict)
	
	var stat1 := Statement.new(expr1)
	var stat2 := Statement.new(expr2)
	
	var loc1 := stat1.get_conclusion()
	var loc2:UniversalLocator = stat2.get_conditions()[1]
	
	var matching = Matching.new(loc2, loc1)
	
	print(matching.is_possible())
	
	#var combination = matching.create_hybrid()
	
	#print(combination.to_string())
