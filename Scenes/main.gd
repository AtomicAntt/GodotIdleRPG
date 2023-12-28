extends Control

@onready var menu: Control = $Menu
@onready var main2D: Node2D = $Main2D

var levelInstance: Node2D

@onready var playerExperienceLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayerExperienceLabel
@onready var playerLevelsLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayerLevelsLabel

@onready var timeSpawnLabel = $Main2D/CanvasLayer/Control/BoxContainer/TimeSpawn
@onready var numMonstersLabel = $Main2D/CanvasLayer/Control/BoxContainer/NumMonsters

@onready var playerEntity := preload("res://GameObjects/PlayerEntity.tscn")

var playerExperience: int = 0
#var playerLevels: int = 1 (Use global)

var maxSpawnLimit: int = 50
var upgradeCost: int = 2
var upgradeLevel

func _ready() -> void:
	loadLevel("World1")
#	print(Time.get_unix_time_from_datetime_dict({
#		"year": 2023,
#		"month": 12,
#		"day": 27,
#		"hour": 1,
#		"minute": 1,
#		"second": 1
#		}))
	print(Time.get_unix_time_from_datetime_dict(Time.get_datetime_dict_from_system()))

func _physics_process(delta) -> void:
	var enemyCount = get_tree().get_nodes_in_group("enemy").size()
	timeSpawnLabel.text = str("%.1f" % $SpawnEnemy.time_left) + "s"
	numMonstersLabel.text = str(enemyCount) + "/" + str(maxSpawnLimit) + " Enemies"

func unloadLevel() -> void:
	if is_instance_valid(levelInstance):
		levelInstance.queue_free()
	levelInstance = null

func loadLevel(levelName: String) -> void:
	unloadLevel()
	var levelPath := "res://Worlds/%s.tscn" % levelName
	var levelResource := load(levelPath)
	if levelResource:
		levelInstance = levelResource.instantiate()
		main2D.add_child(levelInstance)

#func addLevel() -> void:
#	Global.totalLevels += 1
#	updatePlayerLevels() # visually
#	if playerLevels % 2 == 0:
#		addPlayer()

#func updatePlayerLevels() -> void:
#	playerLevelsLabel.text = "PL: " + str(playerLevels)
	
func addPlayer() -> void:
	print("add player")
	if is_instance_valid(get_tree().get_nodes_in_group("spawnPosition")[0]) and is_instance_valid(levelInstance):
		print("add player successfully")
		var playerInstance: CharacterBody2D = playerEntity.instantiate()
		levelInstance.add_child(playerInstance)
		playerInstance.global_position = get_tree().get_nodes_in_group("spawnPosition")[0].global_position

func addExperience(expAmount: int) -> void:
	playerExperience += expAmount
	updatePlayerExperience()
	updateUpgradeAvailability()

func updatePlayerExperience() -> void:
	playerExperienceLabel.text = "PX: " + str(playerExperience)

func updateUpgradeAvailability() -> void:
	if playerExperience >= upgradeCost:
		$Main2D/CanvasLayer/Control/BoxContainer/Button.disabled = false
	else:
		$Main2D/CanvasLayer/Control/BoxContainer/Button.disabled = true

func _on_button_pressed() -> void:
	print($SpawnEnemy.wait_time)
	if $SpawnEnemy.wait_time > 0.1 and playerExperience >= upgradeCost:
#		$SpawnEnemy.stop()
		playerExperience -= upgradeCost
		updatePlayerExperience()
		upgradeCost += upgradeCost/2
		$SpawnEnemy.wait_time /= 1.2
		$Main2D/CanvasLayer/Control/BoxContainer/Button.text = "upgrade enemy spawner\ncost: " + str(upgradeCost) + " PX\nspawn time: " + str("%.1f" % $SpawnEnemy.wait_time) + "s"
#		$SpawnEnemy.start()
		
		updateUpgradeAvailability()
	
	

func _on_spawn_enemy_timeout():
	var enemyCount = get_tree().get_nodes_in_group("enemy").size()
	if enemyCount < maxSpawnLimit:
		var world = get_tree().get_nodes_in_group("world")[0]
		world.spawnEnemyAtRandomLocation()
