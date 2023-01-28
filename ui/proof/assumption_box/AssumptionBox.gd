extends PanelContainer

signal request_unstar

var assumption : ExprItem
var assumption_context : SymmetryBox
var selection_handler : SelectionHandler


func initialise(assumption:ExprItem, assumption_context:SymmetryBox, selection_handler:SelectionHandler):	
	$"%Name".autostring = ExprItemAutostring.new(
		assumption, 
		assumption_context.get_parse_box()
	)
	$"%UseButtons".init(assumption, assumption_context, selection_handler, self)
	
	self.selection_handler = selection_handler
	self.assumption = assumption
	self.assumption_context = assumption_context

