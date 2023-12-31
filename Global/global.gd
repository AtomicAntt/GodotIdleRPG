extends Node

#var dictionarySave: Dictionary
var playerDataArray: Array[Player]
var playerExperience: int = 0

const savePath: String = "user://idlerpgdata.save"

var totalLevel: int:
	get:
		var total: int = 0
		for player in playerDataArray:
			total += player.level
		return total

# Meaning: The amount of players that can be added maximum, which depending on cumulative levels of all players (3 level 3 players = 9 levels cumulative = 4)
var availablePlayers: int:
	get: # Purpose of +2: There will always be 2 available players
		return (totalLevel/3)+2

var totalPlayers: int:
	get:
		return playerDataArray.size()

var canAddPlayer: bool:
	get:
		# If there are 3 total players, each level 3, that means there are 9/2 = 4 more available players
		# Second case: If there are only 0 or 1 players (so this just initialized 2 players)
		if availablePlayers > totalPlayers:
			return true
		else:
			return false

func createNewPlayer() -> Player:
	# This means I am creating a player that needs a name (will be dealt with) at level 1, 0 exp, 20 required exp, and joinTime to be set (will be dealt with)
	var newPlayer: Player = Player.new("", 1, 0, 20, -1, "")
	playerDataArray.append(newPlayer)
	saveGame() # Purpose: Save game after the playerDataArray changes
	return newPlayer

func saveGame() -> void:
	var save_game: FileAccess = FileAccess.open(savePath, FileAccess.WRITE)
	
	var playerEntitiesArray: Array[Dictionary]
	
	# Need to manually unpack all of the data from the player entities
	for playerData in playerDataArray:
		var playerDataDictionary: Dictionary = {
			"name": playerData.name,
			"level": playerData.level,
			"exp": playerData.exp,
			"experienceRequired": playerData.experienceRequired,
			"joinTime": playerData.joinTime,
			"playerLook": playerData.playerLook
		}
		playerEntitiesArray.append(playerDataDictionary)
	
	# Now lets wrap every single data we need to save in a dictionary
	var dictionaryToSave: Dictionary = {
		"playerDataArray": playerEntitiesArray,
		"playerExperience": playerExperience
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
			var playerToAdd: Player = Player.new(playerDictionary["name"], playerDictionary["level"], playerDictionary["exp"], playerDictionary["experienceRequired"], playerDictionary["joinTime"], playerDictionary["playerLook"])
			playerDataArray.append(playerToAdd)
		
		playerExperience = node_data["playerExperience"]

func addExperience(exp: int) -> void:
	playerExperience += exp
	saveGame() #Purpose: Save game whenever PX changes
