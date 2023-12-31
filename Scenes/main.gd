extends Control

@onready var menu: Control = $Menu
@onready var main2D: Node2D = $Main2D

var levelInstances: Array[Node2D]

@onready var playerExperienceLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayerExperienceLabel
@onready var playerLevelsLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayerLevelsLabel

#@onready var timeSpawnLabel = $Main2D/CanvasLayer/Control/BoxContainer/TimeSpawn
#@onready var numMonstersLabel = $Main2D/CanvasLayer/Control/BoxContainer/NumMonsters

@onready var playerEntity := preload("res://GameObjects/PlayerEntity.tscn")

#var playerExperience: int = 0
#var playerLevels: int = 1 (Use global)

var maxSpawnLimit: int = 50
var upgradeCost: int = 2

func _ready() -> void:
	loadLevel("World1")

func unloadLevel() -> void:
	if is_instance_valid(levelInstances[0]):
		levelInstances[0].queue_free()
		levelInstances.pop_front()

func loadLevel(levelName: String) -> void:
	unloadLevel()
	var levelPath := "res://Worlds/%s.tscn" % levelName
	var levelResource := load(levelPath)
	if levelResource:
#		levelInstances = levelResource.instantiate()
		levelInstances.append(levelResource.instantiate())
		main2D.add_child(levelInstances.back()) #This is the thing you just added to the back of the array

# Below 2 functions called by playerEntity nodes

func updateUI() -> void:
	playerLevelsLabel.text = "PL: " + str(Global.totalLevel)
	playerExperienceLabel.text = "PX: " + str(Global.playerExperience)

func addExperience(expAmount: int) -> void:
	Global.addExperience(expAmount)
	updateUI()

# These below 2 functions are used to add players as the game goes on to available worlds

func addPlayer(playerToAdd: Player) -> void:
	if is_instance_valid(levelInstances[0]):
		var bestLevelToPutInto: World = levelInstances[0] # Future: Make the default the town level
		for level in levelInstances:
			# Can I fit the player in this level (50 max)? Is he even able to enter w/ level restrictions?
			if level.playersInside.size() < maxSpawnLimit and playerToAdd.level <= level.maxLevel:
				bestLevelToPutInto = level
		
		var playerInstance: PlayerEntity = playerEntity.instantiate()
		playerInstance.loadPlayerData(playerToAdd)
		bestLevelToPutInto.add_child(playerInstance)
		playerInstance.global_position = bestLevelToPutInto.spawnPosition.global_position
	else:
		print("There are no level instances!")
