class_name ParserInputTape

var tokens : Array
var i := 0

func _init(tokens:Array):
	self.tokens = tokens

func try_eat(token:String) -> bool:
	if done():
		return false
	if tokens[i].contents == token:
		i += 1
		return true
	return false

func done() -> bool:
	return i >= tokens.size()

func peek() -> String:
	if done():
		return ""
	else:
		return tokens[i].contents

func pop() -> Token2:
	i = i + 1
	return tokens[i-1]

func previous() -> Token2:
	return tokens[i-1]

func go_back() -> void:
	i -= 1
