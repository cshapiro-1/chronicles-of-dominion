extends Node

func save_game(slot: String = "save_01") -> bool:
	var data = {
		"resources": EconomyManager.resources,
		"population": PopulationManager.total_population,
		"hope": PopulationManager.hope,
		"discontent": PopulationManager.discontent,
		"year": GameManager.game_year
	}
	var f = FileAccess.open("user://" + slot + ".json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "  "))
		return true
	return false
