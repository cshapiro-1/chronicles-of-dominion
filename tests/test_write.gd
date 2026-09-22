extends SceneTree

func _init() -> void:
	var file = FileAccess.open("user://test_success.txt", FileAccess.WRITE)
	if file:
		file.store_string("HELLO GODOT")
		file.close()
	quit()
