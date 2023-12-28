class_name global

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
	var save_game = FileAccess.open(savePath, FileAccess.WRITE)
	for playerData in playerDataArray:
		var playerDataDictionary: Dictionary = {
			"name": playerData.name,
			"level": playerData.level
		}
	
#func _ready():
#	var player: Player = Player.new("Joe")
#	playerDataArray.append(player)
#
#	print(totalLevel)
#	for playerInstance in playerDataArray:
#		print(playerInstance.name)
