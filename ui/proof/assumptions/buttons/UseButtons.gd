extends HBoxContainer

func init(assumption:ExprItem, proof_box:SymmetryBox, selection_handler:SelectionHandler):
	$"%Star".init(assumption, proof_box, selection_handler)
	$"%Use".init(assumption, proof_box, selection_handler)
	$"%Instantiate".init(assumption, proof_box, selection_handler)
	$"%CaseSplit".init(assumption, proof_box, selection_handler)
	$"%EqLeft".init(assumption, proof_box, selection_handler, true)
	$"%EqRight".init(assumption, proof_box, selection_handler)
	$"%StarL".init(assumption, proof_box, selection_handler)
	$"%StarR".init(assumption, proof_box, selection_handler, true)
	$"%StarLw".init(assumption, proof_box, selection_handler, true)
	$"%StarRw".init(assumption, proof_box, selection_handler)
