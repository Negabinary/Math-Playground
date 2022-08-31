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


var MISSING_JUSTIFICATION = load("res://src/proof_step/justifications/missing_justification.gd")

func add_missing(expr_item:ExprItem):
	var nj = MISSING_JUSTIFICATION.new()
	justifications[expr_item.get_unique_name()] = nj
	expr_items[expr_item.get_unique_name()] = expr_item
	return nj


func merge(other:JustificationMap) -> void:
	for unique_string in other.justifications:
		justifications[unique_string] = other.justifications[unique_string]
	for assumption in other.assumptions:
		assumptions[assumption] = true
	for unique_string in other.expr_items:
		expr_items[unique_string] = other.expr_items[unique_string]


func get_justification_for(expr_item:ExprItem):
	if assumptions.get(expr_item.get_unique_name(), false):
		return AssumptionJustification.new()
	return justifications.get(expr_item.get_unique_name())


func has_justification_for(expr_item:ExprItem) -> bool:
	return has_justification_for_uid(expr_item.get_unique_name())


func has_justification_for_uid(uid:String) -> bool:
	if assumptions.get(uid, false):
		return true
	if justifications.has(uid):
		return true
	return false


func get_assumptions_not_in(other:JustificationMap) -> Array: #<ExprItem>
	var result = []
	for uid in assumptions:
		if not (uid in other.assumptions):
			result.append(expr_items[uid])
	return result


func get_updated_uids(other:JustificationMap):
	var updated_uids := []
	for uid in justifications:
		if justifications.get(uid) != other.justifications.get(uid):
			if not uid in other.assumptions:
				updated_uids.append(uid)
	for uid in other.justifications:
		if not uid in justifications:
			if not uid in assumptions:
				updated_uids.append(uid)
	return updated_uids


func is_assumed(expr_item:ExprItem):
	return assumptions.get(expr_item.get_unique_name(), false)


func duplicate() -> JustificationMap:
	var result:JustificationMap = get_script().new()
	result.merge(self)
	return result
