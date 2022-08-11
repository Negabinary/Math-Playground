class_name JustificationMap

var justifications := {} # <[unique]String, Justification>
var assumptions := {} # <[unique]String, true>
var expr_items := {} # <[unique]String, ExprItem>


func add_entry(expr_item:ExprItem, justification:Justification) -> void:
	justifications[expr_item.get_unique_name()] = justification
	expr_items[expr_item.get_unique_name()] = expr_item


func add_assumption(expr_item:ExprItem) -> void:
	assumptions[expr_item.get_unique_name()] = true
	expr_items[expr_item.get_unique_name()] = expr_item


func merge(other:JustificationMap) -> void:
	for unique_string in other.justifications:
		justifications[unique_string] = other.justifications[unique_string]
	for assumption in other.assumptions:
		assumptions[assumption] = true
	for unique_string in other.expr_items:
		expr_items[unique_string] = other.expr_items[unique_string]


func get_justification_for(expr_item:ExprItem):
	if assumptions.get(expr_item, false):
		return AssumptionJustification.new()
	return justifications.get(expr_item.get_unique_name())


func has_justification_for(expr_item:ExprItem):
	has_justification_for_uid(expr_item.get_unique_name())


func has_justification_for_uid(uid:String):
	if assumptions.get(uid, false):
		true
	return uid in justifications


func is_assumed(expr_item:ExprItem):
	return assumptions.get(expr_item.get_unique_name(), false)


func duplicate() -> JustificationMap:
	var result:JustificationMap = get_script().new()
	result.merge(self)
	return result
