class_name ExprItemEditHelperEdit
extends LineEdit

signal step_left
signal step_right
signal backspace
signal enter



signal done_edit

enum DONE_FLAGS {VALID=1, OPEN=2}

var root
var proof_box

func _init(root, proof_box):
	self.root = root
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


func _input(event):
	if has_focus():
		if event.is_action_pressed("ui_left"):
			if caret_position == 0:
				accept_event()
				emit_signal("step_left")
				root.grab_focus()
				root.caret_helper = self; root.caret_part = 0; root.caret_char = caret_position
				root._jump_left()
		elif event.is_action_pressed("ui_right"):
			if caret_position == text.length():
				accept_event()
				root.caret_char = caret_position
				root.grab_focus()
				root.caret_helper = self; root.caret_part = 0; root.caret_char = caret_position
				root._jump_right()
		elif event.is_action_pressed("ui_accept"):
			if proof_box.parse(text) != null:
				emit_signal("done_edit", proof_box.parse(text), DONE_FLAGS.VALID)
		elif event.is_action_pressed("ui_open"):
			accept_event()
			if proof_box.parse(text) == null:
				emit_signal("done_edit", null, DONE_FLAGS.OPEN)
			else:
				emit_signal("done_edit", proof_box.parse(text), DONE_FLAGS.OPEN + DONE_FLAGS.VALID)
		elif event.is_action_pressed("backspace"):
			if caret_position == 0:
				var parent = get_parent()
				queue_free()
				parent.update()
