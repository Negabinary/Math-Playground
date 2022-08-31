extends VBoxContainer

var selection_handler

func initialise(assumption:ExprItem, context:SymmetryBox, selection_handler:SelectionHandler):
	self.selection_handler = selection_handler
	$HBoxContainer/Name.autostring = ExprItemAutostring.new(
		assumption,
		context.get_parse_box()
	)
	$HBoxContainer2/Star.init(assumption, context, selection_handler)
	$HBoxContainer2/Use.init(assumption, context, selection_handler)
	$HBoxContainer2/Instantiate.init(assumption, context, selection_handler)
	$HBoxContainer2/EqLeft.init(assumption, context, selection_handler, true)
	$HBoxContainer2/EqRight.init(assumption, context, selection_handler)
