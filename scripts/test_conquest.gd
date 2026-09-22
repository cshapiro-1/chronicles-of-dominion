extends Node

func _ready() -> void:
	await get_tree().create_timer(1.2).timeout
	var citadel = get_tree().get_first_node_in_group("EnemyBuildings")
	if citadel:
		citadel.take_damage(2500.0)
	await get_tree().create_timer(1.0).timeout
	var vp = get_viewport()
	var img = vp.get_texture().get_image()
	img.save_png("C:/Users/Collin/.gemini/antigravity/brain/5367374f-06c2-41b9-8ffb-6edccf1d7f91/conquest_victory_render.png")
	print("Captured conquest victory render.")
	get_tree().quit()
