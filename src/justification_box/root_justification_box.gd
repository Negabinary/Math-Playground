extends AbstractJustificationBox
class_name RootJustificationBox

var parse_box : RootParseBox


func _init():
	parse_box = RootParseBox.new()


func _missing_justification(expr_item:ExprItem) -> Justification:
	return MissingJustification.new()


func get_justifications_snapshot() -> JustificationMap:
	return justification_map.duplicate()


func get_parse_box() -> AbstractParseBox:
	return parse_box
