extends Node

var tags := {} # <ExprItemType, Array<Tag>>

func _init():
	_add_global_tags()
	

func _add_global_tags():
	tags[GlobalTypes.TAG] = [Tag.new(_p("TAG"))]
	tags[GlobalTypes.PROP] = [Tag.new(_p("TAG"))]
	tags[GlobalTypes.ANY] = [Tag.new(_p("TAG"))]
	tags[GlobalTypes.F_DEF] = [Tag.new(_p("->(TAG,->(TAG,TAG))"))]
	
	tags[GlobalTypes.IMPLIES] = [Tag.new(_p("->(PROP,->(PROP,PROP))"))]
	tags[GlobalTypes.FORALL] = [Tag.new(_p("->(ANY,->(PROP,PROP))"))] # THIS FEELS VERY IFFFFFYYYY
	tags[GlobalTypes.EXISTS] = [Tag.new(_p("->(ANY,->(PROP,PROP))"))] # THIS FEELS VERY IFFFFFYYYY
	tags[GlobalTypes.EQUALITY] = [Tag.new(_p("->(ANY,->(ANY,PROP))"))] # MAYBE ALL OF THESE NEED TO BE HANDLED SPECIALLY...
	tags[GlobalTypes.NOT] = [Tag.new(_p("->(PROP,PROP)"))]


func _p(s:String)->ExprItem:
	return ExprItemBuilder.from_string(s, GlobalTypes.PROOF_BOX)


func put_tag(type:ExprItemType, tag:Tag) -> void: # ,,<ExprItemType>
	if !tags.has(type):
		tags[type] = [tag]
	else:
		tags[type].append(tag)


func get_type_tags(type:ExprItemType) -> Array:
	return tags.get(type, [])


func is_tag(expr_item:ExprItem):
	var argument_count := expr_item.get_child_count()
	for type_tag in get_type_tags(expr_item.get_type()):
		var tag_ei:ExprItem = type_tag.get_expr_item()
		for i in argument_count:
			if tag_ei.get_type() == GlobalTypes.F_DEF:
				tag_ei = tag_ei.get_child(1)
			else:
				tag_ei = null
		if tag_ei != null:
			if tag_ei.get_type() == GlobalTypes.TAG:
				return true


#func get_tags(expr_item:ExprItem) -> Array:
#	var type := expr_item.get_type()
#	var type_tags := get_type_tags(type) 
#	if type_tags == []:
#		return []
#	var valid_tags = []
#	for tag in type_tags:
#		if _is_valid_tag(tag.get_expr_item(), tag.get_parameters(), expr_item):
#			pass


#func _is_valid_tag(tag_ei, tag_parameters, expr_item, parameters_map):
#	if tag_ei.get_type() == GlobalTypes.ANY:
#		return true
#	elif current_tag.get_type() == GlobalTypes.TAG:
#		if expr_item.get_child_count() == 0:
#			valid_tags.append(GlobalTypes.TAG)
#		elif expr_item.get_child_count() == 1:
#			valid_tags.append(GlobalTypes.PROP)
#		elif expr_item.get_child_count()
