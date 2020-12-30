class_name ExprItemEditHelper
extends Control

signal click_event

signal step_left
signal step_right
signal changed

var EXPR_ITEM_EDIT_HELPER = load("res://ui/components/ei_editor/expr_item_edit_helper.gd")

enum HELPER_MODE {EDIT, VIEW}
var mode:int = HELPER_MODE.EDIT
var root

# VIEW MODE
var type : ExprItemType = null
var proof_box := ProofBox.new([])

var selected := false
var caret_part := 0
var caret_after := false

var bound := false


# == HELPERS ==================================================================

static func sum_array(array:Array) -> int:
	var sum = 0
	for element in array:
		 sum += element
	return sum


func get_fm_strings() -> Array:
	var strings : Array
	if mode == HELPER_MODE.EDIT:
		strings = ["",""]
	else:
		strings = type.get_fm_strings().duplicate()
		if len(strings) > get_child_count() + 1:
			strings = [type.get_identifier()]
	for n in get_child_count() + 1 - len(strings):
		strings[-1] += "("
		strings += [")"]
	return strings


# == INITALISATION ============================================================

func _init(root, expr_item:ExprItem = null, 
		   proof_box:ProofBox = GlobalTypes.PROOF_BOX, bound:=false):
	self.root = root
	connect("changed",root,"_on_changed", [self])
	self.bound = bound
	self.proof_box = proof_box
	if expr_item == null:
		if bound:
			set_type(ExprItemType.new("???"))
			mode = HELPER_MODE.EDIT
			show_editor("???")
		else:
			mode = HELPER_MODE.EDIT
			show_editor("")
	else:
		mode = HELPER_MODE.VIEW
		set_type(expr_item.get_type())
		if type.is_binder():
			append_child(expr_item.get_child(0), proof_box, true)
			var bound_type = expr_item.get_child(0).get_type()
			var new_proof_box = ProofBox.new([bound_type], proof_box)
			append_child(expr_item.get_child(1), new_proof_box)
			for i in range(2, expr_item.get_child_count()):
				append_child(expr_item.get_child(i), proof_box)
		else:
			for child in expr_item.get_children():
				append_child(child, proof_box)


func _ready():
	if mode == HELPER_MODE.EDIT:
		_enter_edit_mode()
	focus_mode = Control.FOCUS_CLICK
	connect("focus_exited", self, "_on_lose_focus")


# == TREE UPDATES =============================================================

func new_binder():
	if get_child_count() == 0 || !get_child(0).bound:
		var binder_child = append_child(null, proof_box, true)
		move_child(binder_child, 0)
		var bound_type = get_child(0).get_type()
		var new_proof_box = ProofBox.new([bound_type], proof_box)
		var new_child = append_child(null, new_proof_box)
		move_child(new_child, 1)


func remove_binder():
	if get_child_count() > 0 && get_child(0).bound:
		var c1 = get_child(0); remove_child(c1); c1.queue_free()
		var c2 = get_child(1); remove_child(c2); c2.queue_free()


func unwrap_binder():
	assert (not (get_child(0).get_type() in get_child(1).get_all_types()))
	assert (false) # TODO


func append_child(expr_item:ExprItem, proof_box, bound:=false) -> ExprItemEditHelper:
	var new_child = get_script().new(root, expr_item, proof_box, bound)
	new_child.connect("step_left", self, "_left_from_above")
	new_child.connect("step_right", self, "_right_from_above")
	new_child.connect("resized", self, "update")
	add_child(new_child)
	update()
	return new_child


func show_editor(string:="", focus:=false) -> void:
	var line_edit := ExprItemEditHelperEdit.new(root, proof_box, bound)
	line_edit.text = string
	line_edit.expand_to_text_length = true
	line_edit.connect("resized", self, "update")
	line_edit.connect("done_edit", self, "_on_edit_done")
	line_edit.connect("step_left", self, "_left_from_above")
	line_edit.connect("step_right", self, "_right_from_above")
	add_child(line_edit)
	move_child(line_edit, 0)
	update()
	
	if focus:
		line_edit.grab_focus()
		line_edit.caret_position = line_edit.text.length()


func _enter_edit_mode(string:="", focus:=true) -> void:
	if mode == HELPER_MODE.VIEW:
		show_editor(string, focus)
	mode = HELPER_MODE.EDIT
	emit_signal("changed")


func _on_edit_done(type, flags:int):
	if flags & ExprItemEditHelperEdit.DONE_FLAGS.BOUND:
		self.type.rename(type)
		_exit_edit_mode()
		right_from_below(true)
		right()
	else:
		if flags & ExprItemEditHelperEdit.DONE_FLAGS.VALID:
			_right_from_above(get_child(0),true)
			set_type(type)
			_exit_edit_mode()
			if type.is_binder():
				new_binder()
			else:
				remove_binder()
		if flags & ExprItemEditHelperEdit.DONE_FLAGS.OPEN:
			if type == null || !type.is_binder():
				var new_child := append_child(null, proof_box)
				if mode == HELPER_MODE.EDIT:
					move_child(new_child, 0)
				else:
					move_child(new_child, 1)
			get_child(0).right_from_below(true)
	emit_signal("changed")
	update()


func _exit_edit_mode() -> void:
	if mode == HELPER_MODE.EDIT:
		if get_child(0) is ExprItemEditHelperEdit:
			get_child(0).queue_free()
			remove_child(get_child(0))
	mode = HELPER_MODE.VIEW
	update()


# == MATH UPDATES =============================================================

func set_proof_box(proof_box:ProofBox) -> void:
	self.proof_box = proof_box
	if type.is_binder():
		var bound_type = get_child(0).get_type()
		var new_proof_box = ProofBox.new([bound_type], proof_box)
		get_child(1).set_proof_box(new_proof_box)
	else:
		for child in get_children():
			child.set_proof_box(proof_box)


func set_type(new_type:ExprItemType) -> void:
	if type != null && type.is_connected("renamed", self, "_on_type_renamed"):
		type.disconnect("renamed", self, "_on_type_renamed")
		type.disconnect("deleted", self, "_on_type_deleted")
	type = new_type
	if type != null:
		type.connect("renamed", self, "_on_type_renamed")
		type.connect("deleted", self, "_on_type_deleted")


# == EXTRACTION ===============================================================

func get_type() -> ExprItemType:
	return type


func has_holes() -> bool:
	for child in get_children():
		if child is ExprItemEditHelperEdit:
			return true
		elif child.has_holes():
			return true
	return false


func get_all_types() -> Dictionary:
	var all_types := {type:1}
	for child in get_children():
		if child.get_type() == get_type():
			var child_types = child.get_all_types()
			for t in child_types:
				all_types[t] = child_types[t] + all_types.get(t, 0)
	return all_types


func get_expr_item() -> ExprItem:
	var ei_children = []
	for child in get_children():
		ei_children.append(child.get_expr_item())
	return ExprItem.new(type, ei_children)



# == SELECTION UPDATES ========================================================

func take_caret(part:int, after:bool):
	self.caret_after = after
	self.caret_part = part
	self.selected = true
	update()
	grab_focus()


func _on_lose_focus():
	self.selected = false
	update()


# We could probably replace these 6 functions with just 2...

func left():
	assert (selected)
	if caret_after:
		take_caret(caret_part, false)
		if caret_part == 0:
			emit_signal("step_left", self, false)
		else:
			get_child(caret_part-1).left_from_below(false)
	else:
		if caret_part == 0:
			emit_signal("step_left", self, true)
		else:
			get_child(caret_part-1).left_from_below(true)


func left_from_below(travel:=false):
	if travel:
		if get_child_count() == 0:
			take_caret(0, false)
			emit_signal("step_left", self, get_fm_strings()[0] == "")
		else:
			get_child(get_child_count()-1).left_from_below(get_fm_strings()[-1] == "")
	else:
		take_caret(get_child_count(), true)


func _left_from_above(from:Node,travel:=true):
	var index_from = from.get_index()
	if travel:
		if index_from == 0:
			take_caret(0, false)
			emit_signal("step_left", self, get_fm_strings()[0] == "")
		else:
			get_child(index_from-1).left_from_below(get_fm_strings()[index_from] == "")
	else:
		if get_fm_strings()[index_from] == "":
			if index_from == 0:
				take_caret(0, false)
				emit_signal("step_left", self, false)
			else:
				get_child(index_from-1).left_from_below(false)
		else:
			take_caret(index_from, true)


func right():
	assert (selected)
	if !caret_after:
		take_caret(caret_part, true)
	else:
		if caret_part == get_child_count():
			emit_signal("step_right", self, true)
		else:
			get_child(caret_part).right_from_below(true)


func right_from_below(travel:=true):
	if travel:
		if get_fm_strings()[0] == "":
			if get_child_count() == 0:
				emit_signal("step_right", self, true)
			else:
				get_child(0).right_from_below(true)
		else:
			take_caret(0, true)
	else:
		take_caret(0, false)


func _right_from_above(from:Node,travel:=false):
	var index_to = from.get_index() + 1
	if travel:
		if get_fm_strings()[index_to] == "":
			if get_child_count() == index_to:
				emit_signal("step_right", self, true)
			else:
				get_child(index_to).right_from_below(true)
		else:
			take_caret(index_to, true)
	else:
		take_caret(index_to, false)


# == INPUT ====================================================================

func _on_type_deleted():
	on_backspace(false)
	update()


func _gui_input(event):
	if event.is_action_pressed("mouse_left"):
		take_caret(get_child_count(), true)
	if event.is_action_pressed("ui_left"):
		accept_event()
		left()
	if event.is_action_pressed("ui_right"):
		accept_event()
		right()
	if event.is_action_pressed("backspace"):
		accept_event()
		on_backspace()
	if event.is_action_pressed("ui_open"):
		accept_event()
		on_open()


func on_backspace(focus:=true):
	if mode == HELPER_MODE.VIEW:
		_enter_edit_mode(type.get_identifier(), focus)
		update()
	elif mode == HELPER_MODE.EDIT:
		update()


func on_open():
	if caret_after:
		if caret_part == get_child_count():
			var child = append_child(null, proof_box)
			child.right_from_below(true)


# == DRAWING =================================================================

func _on_type_renamed():
	update()


func _draw():
	var font : Font = get_font("font", "ExprItemEdit")
	var ascent := font.get_height() - font.get_descent()
	var font_color : Color = get_color("font_color", "ExprItemEdit")
	
	if selected:
		draw_style_box(get_stylebox("highlight_box", "ExprItemEdit"), Rect2(Vector2.ZERO,rect_size))
	
	var strings := get_fm_strings()
	var current_x := 0.0
	var caret_x = null
	
	if mode == HELPER_MODE.EDIT:
		draw_style_box(get_stylebox("exit_box","ExprItemEdit"), Rect2(Vector2(current_x, ascent), font.get_string_size(strings[0])))
	draw_string(font, Vector2(current_x, ascent), strings[0], font_color)
	if selected and caret_part == 0:
		caret_x = current_x + (font.get_string_size(strings[0]).x if caret_after else 0)
	current_x += font.get_string_size(strings[0]).x
	
	for i in len(strings)-1:
		get_child(i).set_position(Vector2(current_x, 0))
		current_x += get_child(i).rect_size.x
		draw_string(font, Vector2(current_x, ascent), strings[i+1], font_color)
		if selected and caret_part - 1 == i:
			caret_x = current_x + (font.get_string_size(strings[i+1]).x if caret_after else 0)
		current_x += font.get_string_size(strings[i+1]).x
	
	if caret_x != null:
		draw_line(
				Vector2(caret_x, 0),
				Vector2(caret_x, font.get_ascent() + font.get_descent()),
				get_color("caret_color","ExprItemEdit"),
				get_constant("caret_width","ExprItemEdit")
			)
	
	set_custom_minimum_size(Vector2(current_x, font.get_ascent() + font.get_descent()))
	set_size(rect_min_size)
	get_parent().update()
