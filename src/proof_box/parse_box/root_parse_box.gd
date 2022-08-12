extends AbstractParseBox
class_name RootParseBox


func parse(identifier:String, module:String) -> ExprItemType:
	return null


func get_name_for(type:ExprItemType) -> String:
	return ","


func get_all_types() -> TwoWayParseMap:
	return TwoWayParseMap.new()
