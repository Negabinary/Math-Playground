extends Node

var TYPING := true

var IMPLIES := ExprItemType.new("=>")
var FORALL := ExprItemType.new("For all")
var EQUALITY := ExprItemType.new("=")
var NOT := ExprItemType.new("¬")
var EXISTS := ExprItemType.new("For some")
var LAMBDA := ExprItemType.new(">>")

var TAG := ExprItemType.new("TAG")
var ANY := ExprItemType.new("ANY")
var PROP := ExprItemType.new("PROP")
var F_DEF := ExprItemType.new("->")

var PROOF_BOX := ProofBox.new([
		IMPLIES, FORALL, EQUALITY, NOT, EXISTS,
		TAG, ANY, PROP, F_DEF
	])

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
