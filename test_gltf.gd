extends SceneTree

func _init() -> void:
	call_deferred("_test")

func _test() -> void:
	var doc = GLTFDocument.new()
	var state = GLTFState.new()
	var global_path = ProjectSettings.globalize_path("res://assets/models/env_date_palm_high.glb")
	print("Global path: ", global_path, " exists: ", FileAccess.file_exists(global_path))
	var err = doc.append_from_file(global_path, state)
	print("append_from_file err: ", err)
	var scene = doc.generate_scene(state)
	print("generate_scene node: ", scene)
	if scene:
		print("Scene child count: ", scene.get_child_count())
		for c in scene.get_children():
			print(" - Child: ", c.name, " type: ", c.get_class())
	quit(0)
