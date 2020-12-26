extends ModuleItem
class_name ModuleItemDefinition

var type : ExprItemType


func _init(module, expr_item_type:=ExprItemType.new("???"), docstring:="").(module,docstring):
	self.type = expr_item_type

# Add more complicated type changing functions later
func rename_type(new_name:String):
	type.rename(new_name)


func get_definition() -> ExprItemType:
	return type
