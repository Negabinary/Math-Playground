extends ModuleItem2
class_name ModuleItem2Assumption

var assumption : ExprItem
var context : SymmetryBox

func _init(context:SymmetryBox, statement:ExprItem):
	proof_box = context.get_child_extended_with(
		[], [statement]
	)
	self.assumption = statement
	self.context = context

func get_assumption() -> ExprItem:
	return assumption

func serialise():
	return {kind="assumption", expr=proof_box.get_parse_box().serialise(assumption)}

func take_type_census(census:TypeCensus) -> TypeCensus:
	census.add_entry("assumption", self, assumption.get_all_types())
	return census


func get_all_assumptions(recursive:bool) -> Array: #<EI>
	return [assumption]
