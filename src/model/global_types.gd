extends Node

var IMPLIES := ExprItemType.new("=>")
var FORALL := ExprItemType.new("For all")
var EQUALITY := ExprItemType.new("=")
var NOT := ExprItemType.new("¬")
var EXISTS := ExprItemType.new("For some")

func get_map() -> Dictionary:
	return {"=>":IMPLIES, "For all":FORALL, "=":EQUALITY, "¬":NOT, "For some":EXISTS}

func get_scope_stack() -> ScopeStack:
	return ScopeStack.new(get_map())
