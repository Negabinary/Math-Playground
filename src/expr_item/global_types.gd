extends Node

var TYPING := true

var IMPLIES := ExprItemType.new("if")
var FORALL := ExprItemType.new("forall")     #  ALWAYS HAS EXACTLY 2 ARGUMENTS
var EQUALITY := ExprItemType.new("=")
var NOT := ExprItemType.new("¬")
var EXISTS := ExprItemType.new("exists")    #  ALWAYS HAS EXACTLY 2 ARGUMENTS
var LAMBDA := ExprItemType.new("lambda")          # ALWAYS HAS AT LEAST 2 ARGUMENTS
var AND := ExprItemType.new("and")
var OR := ExprItemType.new("or")

var TAG := ExprItemType.new("TAG")
var ANY := ExprItemType.new("ANY")
var PROP := ExprItemType.new("PROP")

var PROOF_BOX := ProofBox.new([
		IMPLIES, FORALL, EQUALITY, NOT, EXISTS, LAMBDA, AND, OR,
		TAG, ANY, PROP
	], null)

func _init():
	FORALL.binder = ExprItemType.BINDER.BINDER
	EXISTS.binder = ExprItemType.BINDER.BINDER
	LAMBDA.binder = ExprItemType.BINDER.BINDER
	
	IMPLIES.fm_strings = ["if (",") then (",")"]
	IMPLIES.fm_strings = ["if ","",""]
	FORALL.fm_strings = ["∀",". ",""]
	FORALL.fm_strings = ["∀","",""]
	EQUALITY.fm_strings = [""," = ",""]
	NOT.fm_strings = ["¬",""]
	AND.fm_strings = [""," and ", ""]
	OR.fm_strings = [""," or ",""]
	EXISTS.fm_strings = ["∃",". ", ""]
	LAMBDA.fm_strings = ["λ"," -> ", ""]
	TAG.fm_strings = ["TAG"]
	ANY.fm_strings = ["ANY"]
	PROP.fm_strings = ["PROP"]
	
	IMPLIES.two_line = true
	FORALL.two_line = true


func _ready():
	var tag = ExprItem.new(TAG)
	var any = ExprItem.new(ANY)
	var prop = ExprItem.new(PROP)
	
	var proptoprop = ExprItem.new(TagShorthand.F_DEF, [prop, prop])
	var anytoprop = ExprItem.new(TagShorthand.F_DEF, [any, prop])
	var tagtotag = ExprItem.new(TagShorthand.F_DEF, [tag,tag])
	
	_add_tag(TAG, ExprItem.new(TAG, [tag]))
	_add_tag(ANY, ExprItem.new(TAG, [any]))
	_add_tag(PROP, ExprItem.new(TAG, [prop]))
	
	_add_tag(NOT, ExprItem.new(TagShorthand.F_DEF, [prop,prop,ExprItem.new(NOT)]))
	_add_tag(IMPLIES, ExprItem.new(TagShorthand.F_DEF, [prop,proptoprop,ExprItem.new(IMPLIES)]))
	_add_tag(EQUALITY, ExprItem.new(TagShorthand.F_DEF, [any,anytoprop,ExprItem.new(EQUALITY)]))
	_add_tag(AND, ExprItem.new(TagShorthand.F_DEF, [prop,proptoprop,ExprItem.new(AND)]))
	_add_tag(OR, ExprItem.new(TagShorthand.F_DEF, [prop,proptoprop,ExprItem.new(OR)]))

func _add_tag(type, expr) -> void:
	pass
	# TODO: REPLACE
#	PROOF_BOX.add_tag(
#		ProofStep.new(
#			expr,
#			PROOF_BOX
#		)
#	)
