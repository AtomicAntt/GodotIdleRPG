extends Control

@onready var menu: Control = $Menu
@onready var main2D: Node2D = $Main2D

var levelInstance: Node2D

@onready var playerExperienceLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayerExperienceLabel
@onready var playerLevelsLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayerLevelsLabel

@onready var timeSpawnLabel = $Main2D/CanvasLayer/Control/BoxContainer/TimeSpawn
@onready var numMonstersLabel = $Main2D/CanvasLayer/Control/BoxContainer/NumMonsters

var playerExperience: int = 0
var playerLevels: int = 3

var maxSpawnLimit: int = 20
var upgradeCost: int = 1

func _ready() -> void:
	loadLevel("World1")

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

func addLevel() -> void:
	playerLevels += 1
	updatePlayerLevels() # visually

func updatePlayerLevels() -> void:
	playerLevelsLabel.text = "PL: " + str(playerLevels)

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
		upgradeCost += upgradeCost
		$SpawnEnemy.wait_time /= 1.2
		$Main2D/CanvasLayer/Control/BoxContainer/Button.text = "upgrade enemy spawner\ncost: " + str(upgradeCost) + " PX\nspawn time: " + str("%.1f" % $SpawnEnemy.wait_time) + "s"
#		$SpawnEnemy.start()
		
		updateUpgradeAvailability()
	
	

func _on_spawn_enemy_timeout():
	var enemyCount = get_tree().get_nodes_in_group("enemy").size()
	if enemyCount < maxSpawnLimit:
		var world = get_tree().get_nodes_in_group("world")[0]
		world.spawnEnemyAtRandomLocation()
