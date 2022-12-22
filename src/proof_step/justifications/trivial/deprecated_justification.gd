extends Justification
class_name DeprecatedJustification

var reason := "This justification is no longer considered sound."
 
func _init(reason:String = ""):
	if reason != "":
		self.reason = reason


func serialize(parse_box:AbstractParseBox) -> Dictionary:
	return {
		justification_version=1,
		justification_type="MissingJustification"
	}


func get_requirements_for(expr_item:ExprItem):
	return null


func get_options_for_selection(expr_item:ExprItem, context:AbstractParseBox, selection:Locator):
	var button = Justification.ButtonOption.new(
		ConstantAutostring.new("delete old justification")
	)
	button.connect("pressed", self, "_request_replace", [
		MissingJustification.new()
	])
	return [
		Justification.LabelOption.new(ConstantAutostring.new(
			"Oops! An older version of Math Playground had a mistake."
		), true),
		Justification.LabelOption.new(ConstantAutostring.new(
			reason
		)),
		button
	]


func get_justification_text(parse_box:AbstractParseBox) -> Autostring:
	return ConstantAutostring.new("justification is no longer considered sound")


func _get_all_types() -> Dictionary:
	return {}


func _request_replace(justification:Justification):
	emit_signal("request_replace", justification)
