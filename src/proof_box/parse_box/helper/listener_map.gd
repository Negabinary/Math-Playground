extends MultiMap
class_name ListenerMap

func add_listener(listener:LookupListener):
	append_to(listener.key, listener)

func remove_listener(listener:LookupListener):
	remove_from(listener.key, listener)

func notify_all(key):
	for x in get_all(key):
		x.notify()
