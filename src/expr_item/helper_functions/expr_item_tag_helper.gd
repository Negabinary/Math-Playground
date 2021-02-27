class_name ExprItemTagHelper


var root : ExprItem
var variables : Array
var variable_tags : Dictionary
var arguments : Array
var return_types : Array
var tagged_type : ExprItemType

var valid := true


func _init(root:ExprItem):
	self.root = root
	var locator = Locator.new(root)
	while true:
		if locator.get_type() == GlobalTypes.FORALL:
			variables.append(locator.get_child(0).get_type())
			locator = locator.get_child(1)
		elif locator.get_type() == GlobalTypes.IMPLIES and locator.get_child_count() == 2:
			var new_tag = get_script().new(locator.get_child(0).get_expr_item())
			if new_tag.is_valid():
				variable_tags[new_tag.get_tagged_type()] = new_tag
			else:
				valid = false; return
		else:
			break
	if locator.get_child_count() == 0:
		valid = false; return
	tagged_type = locator.get_child(locator.get_child_count()-1).get_type()
	locator = locator.abandon_lowest(1)
	while true:
		if locator.get_type() == TagShorthand.F_DEF and locator.get_child_count() == 2:
			arguments.append(locator.get_child(0))
			return_types.append(locator.get_child(1))
			locator = locator.get_child(1)
		else:
			break


func get_root() -> ExprItem:
	return root


func get_argument_tag(n:int) -> Locator:
	return null if n >= arguments.size() else arguments[n]


func get_return_tag(n:int) -> Locator:
	return null if n >= return_types.size() else return_types[n]


func is_valid() -> bool:
	return valid


func get_tagged_type() -> ExprItemType:
	return tagged_type



static func tag_to_statement(tag:ExprItem, tagged:ExprItem) -> ExprItem:
	if tag.get_type() == TagShorthand.T_GEN:
		return ExprItem.new(
			GlobalTypes.FORALL,
			[
				tag.get_child(0),
				ExprItem.new(
					GlobalTypes.IMPLIES,
					[
						ExprItem.new(GlobalTypes.TAG, [tag.get_child(0)]),
						tag_to_statement(tag.get_child(1), tagged)
					]
				)
			])
	elif tag.get_type() == TagShorthand.F_DEF:
		var new_type := ExprItem.new(ExprItemType.new(gen_name()))
		return ExprItem.new(
			GlobalTypes.FORALL,
			[
				new_type,
				ExprItem.new(
					GlobalTypes.IMPLIES,
					[
						tag_to_statement(tag.get_child(0), new_type),
						tag_to_statement(tag.get_child(1), tagged.apply(new_type))
					]
				)
			]
		)
	else:
		return tag.apply(tagged)


static func gen_name():
	return "T" + str(int(rand_range(100, 999)))
