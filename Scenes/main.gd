extends Control

@onready var menu: Control = $Menu
@onready var main2D: Node2D = $Main2D
var levelInstance: Node2D

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
