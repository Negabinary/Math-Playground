extends Justification
class_name AbstractEqualityJustification


var location : Locator


func _init(location:Locator):
	self.location = location


# INHERITED ===================================================================

func get_requirements_for(expr_item:ExprItem, context:AbstractParseBox):
	if location == null:
		return null
	if not expr_item.compare(location.get_root()):
		return null
	var replace_with = _get_equality_replace_with(location.get_expr_item(), context)
	if replace_with == null:
		return null
	var replaced_requirement = Requirement.new(
		location.get_root().replace_at(location.get_indeces(), location.get_abandon(), replace_with)
	)
	var requirements = _get_equality_requirements(location.get_expr_item(), context).duplicate()
	requirements.push_front(replaced_requirement)
	return requirements


func get_options_for(expr_item:ExprItem, context:AbstractParseBox):
	var options := []
	options.append(Justification.LabelOption.new("Location: " + context.printout(location.get_expr_item())))
	if location == null or (not expr_item.compare(location.get_root())):
		options.append(Justification.LabelOption.new("Location not valid", true))
	else:
		options.append_array(_get_equality_options(location.get_expr_item(), context))
	return options


func get_justification_text(parse_box:ParseBox):
	return "USING SOME SORT OF REPLACEMENT"


# VIRTUAL =====================================================================

func _get_equality_replace_with(what:ExprItem, context:AbstractParseBox):
	return null


func _get_equality_requirements(what:ExprItem, context:AbstractParseBox):
	return []


func _get_equality_options(what:ExprItem, context:AbstractParseBox):
	return [Justification.LabelOption.new("Abstract justification used", true)]


# LOCATION ====================================================================

func set_location(location:Locator):
	self.location = location
	emit_signal("updated")
