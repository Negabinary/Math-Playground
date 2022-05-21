class_name MiscUtil

static func ordinal(n:int) -> String:
	var x := n + 1
	var y := str(x)
	if y.ends_with("1"):
		return y + "st"
	elif y.ends_with("2"):
		return y + "nd"
	elif y.ends_with("3"):
		return y + "rd"
	else:
		return y + "th"


static func array_get(arr:Array, idx:int, default=null):
	if idx >= arr.size():
		return default
	else:
		return arr[idx]


static func array_set(arr:Array, idx:int, value, default=null):
	if idx >= arr.size():
		for i in range(arr.size(), idx):
			arr.append(default)
		arr.append(value)
	else:
		arr[idx] = value
