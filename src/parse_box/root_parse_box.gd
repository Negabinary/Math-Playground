extends AbstractParseBox
class_name RootParseBox


func parse(identifier:String, module:String) -> ExprItemType:
	return null


func get_name_for(type:ExprItemType) -> String:
	return ","


func get_import_map() -> Dictionary: # <String, AbstractParseBox>
	return {}


func get_all_types() -> TwoWayParseMap:
	return TwoWayParseMap.new()
