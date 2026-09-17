extends Resource
class_name CrisisData

@export var title: String = "Crisis Title"
@export_multiline var description: String = "Crisis Description"
@export var options: Array[String] = ["Option 1", "Option 2"]
@export var option_consequences: Array[String] = ["Consequence 1", "Consequence 2"]

func apply_choice(index: int) -> void:
	match title:
		"Locust Swarm on the Euphrates":
			if index == 0:
				EconomyManager.spend_resources({"Grain": 200.0})
				PopulationManager.modify_discontent(-0.08)
				EventBus.notification_posted.emit("CANAL SLUICES OPENED", "Crop burn stopped the swarm. -200 Grain, -8% Discontent.", Color(0.95, 0.7, 0.2))
			else:
				PopulationManager.modify_hope(-0.12)
				PopulationManager.modify_discontent(0.15)
				EventBus.notification_posted.emit("FAMINE OMENS", "Locusts devastated the southern basin. -12% Hope, +15% Discontent.", Color(0.95, 0.2, 0.2))
		
		"Noble Grain Hoarding":
			if index == 0:
				EconomyManager.add_resources({"Grain": 350.0})
				PoliticsManager.modify_estates(0.0, -15.0, 10.0)
				EventBus.notification_posted.emit("GRANARIES CONFISCATED", "Imperial guards seized patrician grain stores. +350 Grain.", Color(0.4, 0.9, 0.45))
			else:
				PoliticsManager.modify_estates(0.0, 12.0, -10.0)
				PopulationManager.modify_discontent(0.12)
				EventBus.notification_posted.emit("ARISTOCRACY PLACATED", "Nobility maintains private surplus buffers. +12% Discontent.", Color(0.9, 0.8, 0.3))
		
		"Temple Blood Eclipse":
			if index == 0:
				EconomyManager.spend_resources({"Gold": 150.0})
				PoliticsManager.modify_estates(15.0, 0.0, 0.0)
				PopulationManager.modify_hope(0.08)
				EventBus.notification_posted.emit("DIVINE SACRIFICE", "Sacred rites appease the priesthood. +15% Altar Loyalty, +8% Hope.", Color(0.95, 0.82, 0.35))
			else:
				PoliticsManager.modify_estates(-15.0, 0.0, 0.0)
				PopulationManager.modify_discontent(0.10)
				EventBus.notification_posted.emit("OMENS DENOUNCED", "Priests condemn secular arrogance. -15% Altar Loyalty.", Color(0.95, 0.3, 0.3))
