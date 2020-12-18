extends Control
class_name ExprItemEdit


signal selection_changed # Unimplemented
signal expr_item_changed # (valid:bool) # Unimplemented

# set_proof_box



var caret_helper:Node = null
var caret_part := 0
var caret_char := 0

export var editable := true

func _ready():
	set_focus_mode(Control.FOCUS_CLICK)
	connect("focus_exited", self, "_on_focus_exited")


func move_caret(new_helper:Node, new_part:=0, new_char:=0):
	if (caret_helper != null):
		caret_helper.decaret()
	caret_helper = new_helper
	caret_part = new_part
	caret_char = new_char
	if (caret_helper != null):
		print(caret_helper.get_fm_strings())
		caret_helper.caret(caret_part, caret_char)


func _input(event):
	if has_focus():
		if event.is_action_pressed("ui_left"):
			accept_event()
			if caret_helper != null:
				_jump_left()
			print(str(caret_helper, ", ", caret_part, ", ", caret_char))
		elif event.is_action_pressed("ui_right"):
			accept_event()
			if caret_helper != null:
				_jump_right()
			print(str(caret_helper, ", ", caret_part, ", ", caret_char))
	if caret_helper is ExprItemEditHelperEdit:
		print("YES")
		if caret_helper.has_focus():
			if event.is_action_pressed("ui_left"):
				accept_event()
			elif event.is_action_pressed("ui_right"):
				accept_event()


func _gui_input(event):
	if event.is_action_pressed("backspace"):
		accept_event()
		caret_helper.on_backspace()
	elif event is InputEventKey:
		accept_event()
		if event.is_pressed():
			caret_helper.on_key_press(event.as_text())
		


func _jump_left():
	if caret_helper != null:
		if caret_char > 0:
			move_caret(caret_helper, caret_part, 0)
			_caret_deelevate_left()
			_caret_elevate_left()
		elif caret_part > 0:
			_caret_elevate_left()
			_jump_left()
		elif caret_helper.get_parent() != self:
			_caret_deelevate_left()
			_caret_elevate_left()
			_jump_left()


func _jump_right():
	if caret_helper != null:
		if caret_char < caret_helper.get_fm_strings()[caret_part].length():
			move_caret(caret_helper, caret_part, caret_helper.get_fm_strings()[caret_part].length())
		elif caret_part < caret_helper.get_fm_strings().size() - 1:
			_caret_elevate_right()
			_jump_right()
		elif caret_helper.get_parent() != self:
			_caret_deelevate_right()
			_caret_elevate_right()
			_jump_right()


func _step_left():
	if caret_char > 0:
		move_caret(caret_helper, caret_part, caret_char-1)
		_caret_deelevate_left()
		_caret_elevate_left()
	elif caret_part > 0:
		_caret_elevate_left()
		_step_left()
	elif caret_helper.get_parent() != self:
		_caret_deelevate_left()
		_caret_elevate_left()
		_step_left()


func _step_right():
	if caret_char < caret_helper.get_fm_strings()[caret_part].length():
		move_caret(caret_helper, caret_part, caret_char+1)
	elif caret_part < caret_helper.get_fm_strings().size() - 1:
		_caret_elevate_right()
		_step_right()
	elif caret_helper.get_parent() != self:
		_caret_deelevate_right()
		_caret_elevate_right()
		_step_right()


func _caret_elevate_left():
	var new_helper := caret_helper
	var new_part := caret_part
	var new_char := caret_char
	while (new_char == 0 and new_part != 0):
		new_helper = new_helper.get_child(new_part-1)
		new_part = new_helper.get_fm_strings().size() - 1
		new_char = new_helper.get_fm_strings()[new_part].length()
	move_caret(new_helper, new_part, new_char)


func _caret_elevate_right():
	var new_helper := caret_helper
	var new_part := caret_part
	var new_char := caret_char
	while (
		new_char == new_helper.get_fm_strings()[new_part].length()
		and new_part != new_helper.get_fm_strings().size() - 1
	):
		new_helper = new_helper.get_child(new_part)
		new_part = 0
		new_char = 0
	move_caret(new_helper, new_part, new_char)


func _caret_deelevate_left():
	var new_helper := caret_helper
	var new_part := caret_part
	var new_char := caret_char
	while (new_char == 0 and new_part == 0 and new_helper.get_parent() != self):
		new_part = new_helper.get_index()
		new_helper = new_helper.get_parent()
		new_char = new_helper.get_fm_strings()[new_part].length()
	move_caret(new_helper, new_part, new_char)


func _caret_deelevate_right():
	var new_helper := caret_helper
	var new_part := caret_part
	var new_char := caret_char
	while (
		new_char == new_helper.get_fm_strings()[new_part].length()
		and new_part == new_helper.get_fm_strings().size() - 1
		and new_helper.get_parent() != self
	):
		new_part = new_helper.get_index() + 1
		new_helper = new_helper.get_parent()
		new_char = 0
	move_caret(new_helper, new_part, new_char)


func set_expr_item(expr_item:ExprItem) -> void:
	if get_child_count() == 1:
		get_child(0).queue_free()
	var child := ExprItemEditHelper.new(self, self)
	add_child(child)
	child.set_expr_item(expr_item, GlobalTypes.PROOF_BOX) #TODO CHANGE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	child.connect("minimum_size_changed", self, "_on_minimum_size_change")


func _on_minimum_size_change():
	set_custom_minimum_size(get_child(0).rect_min_size)

func _on_click_event(new_selection, event):
	if !has_focus():
		grab_focus()
	move_caret(
		new_selection, 
		new_selection.get_fm_strings().size() - 1,
		new_selection.get_fm_strings()[-1].length()
	)


func _on_focus_exited():
	move_caret(null, 0, 0)
