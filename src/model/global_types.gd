extends Node

var IMPLIES := ExprItemType.new("=>")
var FORALL := ExprItemType.new("For all")
var EQUALITY := ExprItemType.new("=")
var NOT := ExprItemType.new("¬")
var EXISTS := ExprItemType.new("For some")

var TAG := ExprItemType.new("TAG")
var ANY := ExprItemType.new("ANY")
var PROP := ExprItemType.new("PROP")
var F_DEF := ExprItemType.new("->")

func get_map() -> Dictionary:
	return {
		"=>":IMPLIES, 
		"For all":FORALL, 
		"=":EQUALITY, 
		"¬":NOT, 
		"For some":EXISTS,
		"TAG":TAG,
		"ANY":ANY,
		"PROP":PROP,
		"->":F_DEF,
	}

func get_scope_stack() -> ScopeStack:
	return ScopeStack.new(get_map())
