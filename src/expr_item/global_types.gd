extends Node

var TYPING := true

var IMPLIES := ExprItemType.new("=>")
var FORALL := ExprItemType.new("For all")     #  ALWAYS HAS EXACTLY 2 ARGUMENTS
var EQUALITY := ExprItemType.new("=")
var NOT := ExprItemType.new("¬")
var EXISTS := ExprItemType.new("For some")    #  ALWAYS HAS EXACTLY 2 ARGUMENTS
var LAMBDA := ExprItemType.new(">>")          # ALWAYS HAS AT LEAST 2 ARGUMENTS

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
	
	IMPLIES.fm_strings = ["if (",") then (",")"]
	FORALL.fm_strings = ["∀",". ",""]
	EQUALITY.fm_strings = [""," = ",""]
	NOT.fm_strings = ["¬",""]
	EXISTS.fm_strings = ["∃",". ", ""]
	LAMBDA.fm_strings = ["λ"," -> ", ""]
	TAG.fm_strings = ["TAG"]
	ANY.fm_strings = ["ANY"]
	PROP.fm_strings = ["PROP"]
	F_DEF.fm_strings = ["(",") -> ", ""]


func _ready():
	var tag = ExprItem.new(TAG)
	var any = ExprItem.new(ANY)
	var prop = ExprItem.new(PROP)
	
	var proptoprop = ExprItem.new(F_DEF, [prop, prop])
	var anytoprop = ExprItem.new(F_DEF, [any, prop])
	var tagtotag = ExprItem.new(F_DEF, [tag,tag])
	
	_add_tag(TAG, ExprItem.new(TAG, [tag]))
	_add_tag(ANY, ExprItem.new(TAG, [any]))
	_add_tag(PROP, ExprItem.new(TAG, [prop]))
	
	_add_tag(NOT, ExprItem.new(F_DEF, [prop,prop,ExprItem.new(NOT)]))
	_add_tag(IMPLIES, ExprItem.new(F_DEF, [prop,proptoprop,ExprItem.new(IMPLIES)]))
	_add_tag(EQUALITY, ExprItem.new(F_DEF, [any,anytoprop,ExprItem.new(EQUALITY)]))
	_add_tag(F_DEF, ExprItem.new(F_DEF, [tag, tagtotag, ExprItem.new(F_DEF)]))


func _add_tag(type, expr) -> void:
	PROOF_BOX.add_tag(
		ProofStep.new(
			expr
		)
	)


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
