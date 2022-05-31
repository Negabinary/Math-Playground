extends Node

var F_DEF := ExprItemType.new("->")
var T_GEN := ExprItemType.new("<>")


func _init():
	T_GEN.binder = ExprItemType.BINDER.BINDER
	
	F_DEF.fm_strings = ["(",") -> ", ""]
	T_GEN.fm_strings = ["<",">",""]
