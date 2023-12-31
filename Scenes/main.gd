class_name Main
extends Control

@onready var menu: Control = $Menu
@onready var main2D: Node2D = $Main2D

var levelInstances: Array[Node2D]

@onready var playerExperienceLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayerExperienceLabel
@onready var playerLevelsLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayerLevelsLabel
@onready var playerTotalLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayersTotalLabel

@onready var playerSpawnTimer = $PlayerSpawnTimer

#@onready var timeSpawnLabel = $Main2D/CanvasLayer/Control/BoxContainer/TimeSpawn
#@onready var numMonstersLabel = $Main2D/CanvasLayer/Control/BoxContainer/NumMonsters

@onready var playerEntity := preload("res://GameObjects/PlayerEntity.tscn")

#var playerExperience: int = 0
#var playerLevels: int = 1 (Use global)

var maxSpawnLimit: int = 50
var upgradeCost: int = 2

func _ready() -> void:
	Global.loadGame()	
	loadLevel("World1")
#	Global.loadGame()
	updateUI()
	

func unloadLevel() -> void:
	if levelInstances.size() <= 0:
		return

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
	playerTotalLabel.text = "TP: " + str(Global.totalPlayers)

func addExperience(expAmount: int) -> void:
	Global.addExperience(expAmount)
	updateUI()

# These below 3 functions are used to add players as the game goes on to available worlds

func addPlayer(playerToAdd: Player) -> void:
	if levelInstances.size() <= 0:
		return
	
	if is_instance_valid(levelInstances[0]):
		var bestLevelToPutInto: World = null # If nothing, last resort is town
		for level in levelInstances:
			# Can I fit the player in this level (50 max)? Is he even able to enter w/ level restrictions?
			if level.playersInside.size() < maxSpawnLimit and playerToAdd.level <= level.maxLevel:
				bestLevelToPutInto = level
		if bestLevelToPutInto != null:
			# Here is actually adding the player once the checks are all done.
			bestLevelToPutInto.playersInside.append(playerToAdd)
			var playerInstance: PlayerEntity = playerEntity.instantiate()
			bestLevelToPutInto.add_child(playerInstance)
			playerInstance.loadPlayerData(playerToAdd)
			playerInstance.global_position = bestLevelToPutInto.spawnPosition.global_position
			updateUI() # Purpose: Adding a player actually adds a level
		else:
			print("There is literally no space to put anyone anywhere!")
	else:
		print("There are no level instances!")

func getTakenPlayers() -> Array[Player]:
	var takenPlayers: Array[Player]
	for level in levelInstances:
		takenPlayers.append_array(level.playersInside)
	return takenPlayers

func _on_player_spawn_timer_timeout():
	var playerToSpawn: Player = null
	# First, can I just add a new guy in this MMO (First priority)?
	if Global.canAddPlayer:
		print("Adding entirely new player")
		playerToSpawn = Global.createNewPlayer()
	else:
		# Hmm, now we need to get a player that isnt in one of those playerInside arrays that the current worlds have
		for player in Global.playerDataArray:
			if player not in getTakenPlayers():
				playerToSpawn = player
				break # To make it so the last player isnt the guy added at the end
				
	if playerToSpawn != null:
		addPlayer(playerToSpawn)

func fillWorld(worldInstance: World) -> void:
	if levelInstances.size() <= 0:
		return
	
	# For (50) times, spawn player that is not taken already (this wont spawn completely new peoples) at random ground non adjacent to path or void
	for i in range(maxSpawnLimit):
		var playerToSpawn: Player = null
		for player in Global.playerDataArray:
			if player not in getTakenPlayers():
				playerToSpawn = player
				break # To make it so the last player isnt the guy added at the end
		if playerToSpawn != null:
			worldInstance.playersInside.append(playerToSpawn)
			var playerInstance: PlayerEntity = playerEntity.instantiate()
			worldInstance.add_child(playerInstance)
			playerInstance.loadPlayerData(playerToSpawn)
			playerInstance.global_position = worldInstance.returnValidPlayerLocation()
			updateUI() # Purpose: Adding a player actually adds a level
