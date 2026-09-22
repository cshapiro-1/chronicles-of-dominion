extends Resource
class_name CrisisData

@export var title: String = "Crisis Title"
@export_multiline var description: String = "Crisis Description"
@export var options: Array[String] = ["Option 1", "Option 2"]
@export var option_consequences: Array[String] = ["Consequence 1", "Consequence 2"]

func apply_choice(index: int) -> void:
	match title:
		"Pestilence in the Mudbrick Quarters":
			if index == 0:
				EconomyManager.spend_resources({"Gold": 100.0})
				PopulationManager.modify_population(-5)
				PopulationManager.modify_discontent(-0.05)
				EventBus.notification_posted.emit("QUARANTINE ENFORCED", "Apothecary wards contained the disease. -100 Gold, -5 Pop.", Color(0.4, 0.9, 0.45))
			else:
				PopulationManager.modify_population(-25)
				PopulationManager.modify_discontent(0.20)
				PopulationManager.modify_hope(-0.15)
				EventBus.notification_posted.emit("EPIDEMIC RAGES", "Disease swept through unwashed alleys. -25 Pop, +20% Discontent.", Color(0.95, 0.25, 0.25))

		"Theocratic Tithe Dominance":
			if index == 0:
				PoliticsManager.modify_estates(15.0, 0.0, -10.0)
				EconomyManager.deltas["Gold"] = max(10.0, EconomyManager.deltas.get("Gold", 80.0) - 25.0)
				EventBus.notification_posted.emit("TEMPLE EXEMPTION", "High Priesthood granted sacred trade monopoly. Economy income reduced.", Color(0.95, 0.82, 0.35))
			else:
				PoliticsManager.modify_estates(-25.0, 0.0, 15.0)
				EconomyManager.deltas["Gold"] = EconomyManager.deltas.get("Gold", 80.0) + 20.0
				EventBus.notification_posted.emit("ROYAL SOVEREIGNTY", "Crown asserted control over temple treasuries. +15% Commoners Loyalty.", Color(0.4, 0.85, 0.95))

		"Granary Bread Riots":
			if index == 0:
				EconomyManager.spend_resources({"Grain": 200.0})
				PoliticsManager.modify_estates(0.0, 0.0, 15.0)
				PopulationManager.modify_discontent(-0.10)
				EventBus.notification_posted.emit("GRAIN DISTRIBUTED", "Imperial granaries fed the starving populace. Bread riots subsided.", Color(0.4, 0.95, 0.5))
			else:
				PopulationManager.modify_population(-10)
				PoliticsManager.modify_estates(0.0, 10.0, -15.0)
				PopulationManager.modify_discontent(0.15)
				EventBus.notification_posted.emit("REBELLION SUPPRESSED", "Spearmen quelled the riot by force. -10 Pop, -15% Masses Loyalty.", Color(0.95, 0.2, 0.2))

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

		"Locust Swarm on the Euphrates":
			if index == 0:
				EconomyManager.spend_resources({"Grain": 200.0})
				PopulationManager.modify_discontent(-0.08)
				EventBus.notification_posted.emit("CANAL SLUICES OPENED", "Crop burn stopped the swarm. -200 Grain, -8% Discontent.", Color(0.95, 0.7, 0.2))
			else:
				PopulationManager.modify_hope(-0.12)
				PopulationManager.modify_discontent(0.15)
				EventBus.notification_posted.emit("FAMINE OMENS", "Locusts devastated the southern basin. -12% Hope, +15% Discontent.", Color(0.95, 0.2, 0.2))
