class_name ExprItemEditHelperEdit
extends LineEdit

signal step_left
signal step_right
signal backspace
signal done_edit

enum DONE_FLAGS {VALID=1, OPEN=2, COMMA=4, BOUND=8}

var root
var bound
var proof_box

func _init(root, proof_box, bound:=false):
	self.root = root
	self.proof_box = proof_box
	self.bound = bound
	add_stylebox_override("normal",load("res://theme/LineEdit/ExprItemEditTexture.tres"))

func set_proof_box(proof_box:ProofBox):
	self.proof_box = proof_box

func get_fm_strings():
	return [text]

func decaret():
	print("DECARET")

func caret(caret_part, caret_char):
	assert (caret_part == 0)
	caret_position = caret_char
	grab_focus()
	print("YOO")


func left_from_below(travel:=false):
	grab_focus()
	caret_position = min(1,text.length()) if travel else 0


func right_from_below(travel:=false):
	grab_focus()
	caret_position = max(0,text.length()-1) if travel else text.length()


func _input(event):
	if has_focus():
		if event.is_action_pressed("ui_left"):
			if caret_position == 0:
				accept_event()
				emit_signal("step_left", self, false)
		elif event.is_action_pressed("ui_right"):
			if caret_position == text.length():
				accept_event()
				emit_signal("step_right", self, false)
		elif event.is_action_pressed("backspace"):
			if caret_position == 0:
				accept_event()
				emit_signal("backspace")
		elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_close"):
			if bound:
				accept_event()
				emit_signal("done_edit", text, DONE_FLAGS.BOUND)
			else:
				if proof_box.parse(text) != null:
					accept_event()
					emit_signal("done_edit", proof_box.parse(text), DONE_FLAGS.VALID)
		elif event.is_action_pressed("ui_open"):
			accept_event()
			if bound:
				emit_signal("done_edit", text, DONE_FLAGS.BOUND + DONE_FLAGS.OPEN)
			else:
				if proof_box.parse(text) == null:
					emit_signal("done_edit", null, DONE_FLAGS.OPEN)
				else:
					emit_signal("done_edit", proof_box.parse(text), DONE_FLAGS.OPEN + DONE_FLAGS.VALID)
