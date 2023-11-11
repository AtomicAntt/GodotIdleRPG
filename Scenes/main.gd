extends Control

@onready var menu: Control = $Menu
@onready var main2D: Node2D = $Main2D

var levelInstance: Node2D

@onready var playerExperienceLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayerExperienceLabel
@onready var playerLevelsLabel = $Main2D/CanvasLayer/Control/VBoxContainer/PlayerLevelsLabel

var playerExperience: int = 0
var playerLevels: int = 3

func _ready() -> void:
	loadLevel("World1")

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

func updatePlayerExperience() -> void:
	playerExperienceLabel.text = "PX: " + str(playerExperience)


func _on_button_pressed() -> void:
	var world = get_tree().get_nodes_in_group("world")[0]
	world.spawnEnemyAtRandomLocation()
