extends AbstractParseBox
class_name RootParseBox



func parse(ib:IdentifierBuilder) -> ExprItemType:
	return null


func get_all_types() -> TwoWayParseMap:
	return TwoWayParseMap.new()


func get_il_for(type:ExprItemType) -> IdentifierListener:
	return null


func remove_listener(il:IdentifierListener) -> void:
	pass


func get_listeners_for(identifier:String) -> Array:
	return []


func is_inside(other:AbstractParseBox) -> bool:
	return other == self
