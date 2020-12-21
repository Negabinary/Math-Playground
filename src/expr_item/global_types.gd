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
		IMPLIES, FORALL, EQUALITY, NOT, EXISTS, LAMBDA,
		TAG, ANY, PROP, F_DEF
	])

func _init():
	FORALL.binder = true
	EXISTS.binder = true
	LAMBDA.binder = true
	
	IMPLIES.fm_strings = ["(",") => ",""]
	FORALL.fm_strings = ["@A ",". (",")"]
	EQUALITY.fm_strings = [""," = ",""]
	NOT.fm_strings = ["¬",""]
	EXISTS.fm_strings = ["@E",". (", ")"]
	LAMBDA.fm_strings = ["λ"," -> (", ")"]
	TAG.fm_strings = ["TAG"]
	ANY.fm_strings = ["ANY"]
	PROP.fm_strings = ["PROP"]
	F_DEF.fm_strings = ["(",") -> ", ""]

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
