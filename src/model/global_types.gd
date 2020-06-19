extends Node

var IMPLIES := ExprItemType.new("=>")
var FORALL := ExprItemType.new("For all")
var EQUALITY := ExprItemType.new("=")

func get_map() -> Dictionary:
	return {"=>":IMPLIES, "For all":FORALL, "=":EQUALITY}
