extends Justification
class_name SeparateBiimplicationJustification 

var leftwards := false


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="SeparateBiimplicationJustification",
	}


func _init(leftwards):
	self.leftwards = leftwards
	emit_signal("updated")


func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	var ei_statement := Statement.new(expr_item)
	var ei_conclusion = ei_statement.get_conclusion()
	var implication = ei_conclusion.get_parent()
	if implication == null:
		return null
	if implication.get_type() != GlobalTypes.IMPLIES or implication.get_child_count() != 2:
		return null
	var lhs = implication.get_child(0).get_expr_item()
	var rhs = implication.get_child(1).get_expr_item()
	var equality = ExprItem.new(
		GlobalTypes.EQUALITY,
		[rhs, lhs] if leftwards else [lhs, rhs]
	)
	return [
		Requirement.new(
			implication.get_root().replace_at(
				implication.get_indeces(),
				implication.get_abandon(),
				equality
			)
		)
	]


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	var options = []
	return options


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("going leftwards," if leftwards else "going rightwards,")
