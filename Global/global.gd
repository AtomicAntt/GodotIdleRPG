class_name global

#var dictionarySave: Dictionary
var playerDataArray: Array[Player]
var totalPX: int = 0

const savePath: String = "user://idlerpgdata.save"

var totalLevel: int:
	get:
		var total: int = 0
		for player in playerDataArray:
			total += player.level
		return total

func saveGame() -> void:
	var save_game: FileAccess = FileAccess.open(savePath, FileAccess.WRITE)
	
	var playerEntitiesArray: Array[Dictionary]
	
	# Need to manually unpack all of the data from the player entities
	for playerData in playerDataArray:
		var playerDataDictionary: Dictionary = {
			"name": playerData.name,
			"level": playerData.level,
			"exp": playerData.exp,
			"joinTime": playerData.joinTime
		}
		playerEntitiesArray.append(playerDataDictionary)
	
	# Now lets wrap every single data we need to save in a dictionary
	var dictionaryToSave: Dictionary = {
		"playerDataArray": playerEntitiesArray,
		"totalPX": totalPX
	}
	
	var json_string: String = JSON.stringify(dictionaryToSave)
	
	save_game.store_line(json_string)

func loadGame() -> void:
	if not FileAccess.file_exists(savePath):
		print("Nothing to load!")
		return
	
	var save_game: FileAccess = FileAccess.open(savePath, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string := save_game.get_line()
		
		var json := JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var node_data: Dictionary = json.get_data()
		
		# Refill the variables listed above
		for playerDictionary in node_data["playerDataArray"]:
			var playerToAdd: Player = Player.new(playerDictionary["name"], playerDictionary["level"], playerDictionary["exp"], playerDictionary["joinTime"])
			playerDataArray.append(playerToAdd)
		
		totalPX = node_data["totalPX"]

