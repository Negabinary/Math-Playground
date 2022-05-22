extends ItemList

var definitions := []
var equalities := []
var context : ProofBox
var locator : Locator
var selected_locator : Locator

func add_equalities(locator:Locator):
	self.locator = locator
	equalities = [locator.get_child(0), locator.get_child(1)]
	for equality in equalities:
		add_item(equality.to_string())


func update_context(locator:Locator, context:ProofBox):
	selected_locator = locator
	self.context = context
	var valid = false
	var valid_with_sub = false
	for i in equalities.size():
		var equality = equalities[i]
		var matching := {}
		for definition in definitions:
			matching[definition] = "*"
		if equality.get_expr_item().compare(locator.get_expr_item()):
			set_item_custom_bg_color(1-i, Color8(142,166,4,100))
			update()
		elif equality.get_expr_item().is_superset(locator.get_expr_item(), matching):
			set_item_custom_bg_color(1-i, Color8(142,166,4,50))
			update()
		else:
			set_item_custom_bg_color(1-i, Color8(142,166,4,0))
			update()


func clear_highlighting():
	for i in equalities.size():
		set_item_custom_bg_color(i, Color8(142,166,4,0))
		update()


func _on_item_activated(index):
	var modus_ponens = ModusPonensJustification.new(
		locator.get_root()
	)
	var justification = EqualityJustification.new(
		selected_locator, locator.get_expr_item(), index == 1
	)
