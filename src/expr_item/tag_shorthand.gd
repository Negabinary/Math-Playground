extends Node

var F_DEF := ExprItemType.new("->")
var T_GEN := ExprItemType.new("<>")


func _init():
	T_GEN.binder = ExprItemType.BINDER.BINDER
	
	F_DEF.fm_strings = ["(",") -> ", ""]
	T_GEN.fm_strings = ["<",">",""]


func make_proof_box(proof_box:ProofBox) -> ProofBox:
	return ProofBox.new(
		proof_box,
		[F_DEF, T_GEN]
	)
