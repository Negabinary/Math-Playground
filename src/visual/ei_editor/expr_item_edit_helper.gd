class_name ExprItemEditHelper
extends Control

signal click_event

onready var EXPR_ITEM_EDIT_HELPER = load("res://src/visual/ei_editor/expr_item_edit_helper.gd")

enum HELPER_MODE {EDIT, VIEW}
var mode:int = HELPER_MODE.VIEW
var root

# VIEW MODE
var type : ExprItemType = null
var proof_box : ProofBox = null

var selected := false
var caret_part := 0
var caret_char := 0
var parent


func _init(parent, root):
	self.root = root
	self.parent = parent
	connect("click_event", parent, "_on_click_event")
	_enter_edit_mode()


func _gui_input(event):
	if event.is_action_pressed("mouse_left"):
		emit_signal("click_event", self, event)


func caret(part, chr):
	selected = true; caret_part = part; caret_char = chr
	update()


func decaret():
	selected = false
	update()


func set_expr_item(expr_item:ExprItem, proof_box:ProofBox) -> void:
	type = expr_item.get_type()
	self.proof_box = proof_box
	var new_proof_box:ProofBox
	if type.binder:
		new_proof_box = ProofBox.new([expr_item.get_child(0).get_type()], proof_box)
	else:
		new_proof_box = proof_box
		
	for child in expr_item.get_children():
		var child_edit = EXPR_ITEM_EDIT_HELPER.new(parent, root)
		add_child(child_edit)
		child_edit.set_expr_item(child, new_proof_box)
	_exit_edit_mode()
	update()


func on_backspace():
	if mode == HELPER_MODE.VIEW:
		_enter_edit_mode(type.get_identifier())
		update()
	elif mode == HELPER_MODE.EDIT:
		update()


func on_key_press(character:String):
	if mode == HELPER_MODE.EDIT:
		update()


func _enter_edit_mode(string:="") -> void:
	if mode == HELPER_MODE.VIEW:
		var line_edit := ExprItemEditHelperEdit.new(root, proof_box)
		line_edit.text = string
		line_edit.expand_to_text_length = true
		line_edit.connect("resized", self, "update")
		line_edit.connect("done_edit", self, "_on_edit_done")
		add_child(line_edit)
		move_child(line_edit, 0)
		line_edit.grab_focus()
		line_edit.caret_position = line_edit.text.length()
		line_edit.set_custom_minimum_size(Vector2(0,0))
	mode = HELPER_MODE.EDIT


func _on_edit_done(type:ExprItemType, flags:int):
	if flags & ExprItemEditHelperEdit.DONE_FLAGS.VALID:
		self.type = type
		_exit_edit_mode()
	if flags & ExprItemEditHelperEdit.DONE_FLAGS.OPEN:
		var child:ExprItemEditHelper = EXPR_ITEM_EDIT_HELPER.new(parent, root)
		add_child(child)
		move_child(child, 0)
		child.set_expr_item(ExprItem.new(GlobalTypes.ANY), proof_box)
		child._enter_edit_mode()
	else:
		emit_signal("click_event")


func _exit_edit_mode() -> void:
	if mode == HELPER_MODE.EDIT:
		if get_child(0) is ExprItemEditHelperEdit:
			get_child(0).queue_free()
	mode = HELPER_MODE.VIEW


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
		caret_x = current_x + font.get_string_size(strings[0].left(caret_char)).x
	current_x += font.get_string_size(strings[0]).x
	
	for i in len(strings)-1:
		get_child(i).set_position(Vector2(current_x, 0))
		current_x += get_child(i).rect_size.x
		draw_string(font, Vector2(current_x, ascent), strings[i+1], font_color)
		if selected and caret_part - 1 == i:
			caret_x = current_x + font.get_string_size(strings[i+1].left(caret_char)).x
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

static func sum_array(array:Array) -> int:
	var sum = 0
	for element in array:
		 sum += element
	return sum
