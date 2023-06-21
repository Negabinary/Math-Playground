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


func has_import(import:String) -> LookupListener:
	return LookupListener.new(import, false)


# Addition Listeners ======================================

func add_addition_listener(al:ParseAdditionListener) -> void:
	pass


func remove_addition_listener(al:ParseAdditionListener) -> void:
	pass
