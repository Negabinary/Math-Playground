extends VBoxContainer

var selection_handler

func initialise(assumption:ExprItem, context:SymmetryBox, selection_handler:SelectionHandler):
	self.selection_handler = selection_handler
	$HBoxContainer/Name.autostring = ExprItemAutostring.new(
		assumption,
		context.get_parse_box()
	)
	$"%UseButtons".init(assumption, context, selection_handler)
