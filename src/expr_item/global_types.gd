extends Node

var TYPING := true

var IMPLIES := ExprItemType.new("if")
var FORALL := ExprItemType.new("forall")     #  ALWAYS HAS EXACTLY 2 ARGUMENTS
var EQUALITY := ExprItemType.new("=")
var NOT := ExprItemType.new("¬")
var EXISTS := ExprItemType.new("exists")    #  ALWAYS HAS EXACTLY 2 ARGUMENTS
var LAMBDA := ExprItemType.new("lambda")    #  ALWAYS HAS AT LEAST 2 ARGUMENTS
var AND := ExprItemType.new("and")
var OR := ExprItemType.new("or")
var EOF := ExprItemType.new("eof")

func get_root_symmetry() -> SymmetryBox:
	return SymmetryBox.new(
		JustificationBox.new(
			RootJustificationBox.new(),
			[ExprItem.new(EOF)]
		),
		ParseBox.new(
			RootParseBox.new(),
			[
				IMPLIES, FORALL, EQUALITY, NOT, EXISTS, LAMBDA, AND, OR, EOF
			]
		)
	)

func _init():
	FORALL.binder = ExprItemType.BINDER.BINDER
	EXISTS.binder = ExprItemType.BINDER.BINDER
	LAMBDA.binder = ExprItemType.BINDER.BINDER
	
	IMPLIES.two_line = true
	FORALL.two_line = true
