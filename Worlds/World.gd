class_name World
extends Node2D

# Variables that determine different types of worlds:

@export var worldName: String

# Index 0 sprite goes with index 0 attack
@export var enemySprite: Array[Texture]
@export var enemyAttack: Array[Texture]
@export var enemyDamage: Array[int]
@export var enemyHealth: Array[int]
@export var enemyExpValue: Array[int]

#maxLevel in main node section also technecially belongs here but just assume all export vars are differentiating them

# ----------------------------------------------------

# Save/load these variables:

var upgradeLevel: int

# ----------------------------------------------------

# This is for the main node to see, to make sure they are able to put players and also to know what players to put in:

var playersInside: Array[Player]
@export var maxLevel: int # This is only meant to be a recommendation: If you have level 15 zone but a level 20 player wants to join, it will not unless there is no other worlds.

#------------------------------------------------------

@onready var tileMap: TileMap = $TileMap
@onready var camera2D: Camera2D = $Camera2D
@onready var spawnPosition: Marker2D = $SpawnPosition

@onready var EnemyEntity := preload("res://GameObjects/EnemyEntity.tscn")

var validEnemyLocations: Array # Array of vector2
var validPlayerLocations: Array # Array of vector2

@onready var timeSpawnLabel = $CanvasLayer/Control/BoxContainer/TimeSpawn
@onready var numMonstersLabel = $CanvasLayer/Control/BoxContainer/NumMonsters

@onready var main = get_tree().get_nodes_in_group("main")[0]

var groundTerrainSet: int = 0
var rng := RandomNumberGenerator.new()

var maxSpawnLimit: int = 50
var upgradeCost: int = 2

func getEnemyCount() -> int:
	var enemyCount: int = 0
	
	for node in self.get_children():
		if node.is_in_group("enemy"):
			enemyCount += 1
	
	return enemyCount

func _physics_process(delta) -> void:
	timeSpawnLabel.text = str("%.1f" % $SpawnEnemy.time_left) + "s"
	numMonstersLabel.text = str(getEnemyCount()) + "/" + str(maxSpawnLimit) + " Enemies"

func _ready() -> void:
	# Reason for this function: Need to remove navigation from tiles where obstacles like water is present.
	replaceGroundAtObstacles()
	recordValidEnemyPositions()
	recordValidPlayerPositions()
	fillBoundary()

func fillBoundary() -> void:
	const boundarySourceID: int = 1
	const boundaryAtlasCoordinate: Vector2i = Vector2i(17, 2)
	for cellPosX in range(-100,101):
		for cellPosY in range(-100, 101):
			if tileMap.get_cell_source_id(getLayerIDByName("Ground"), Vector2i(cellPosX, cellPosY)) == -1 and tileMap.get_cell_source_id(getLayerIDByName("Boundary"), Vector2i(cellPosX, cellPosY)) == -1 :
				tileMap.set_cell(getLayerIDByName("Boundary"), Vector2i(cellPosX, cellPosY), boundarySourceID, boundaryAtlasCoordinate)
	
	#For some reason, this not work because probably terrain bitmask is no good, so this function shall only make things dark
#	tileMap.set_cells_terrain_connect(getLayerIDByName("Darkness"), tileMap.get_used_cells(getLayerIDByName("Darkness")), darknessTerrainSet, darknessTerrain, false)
	

func replaceGroundAtObstacles() -> void:
	var groundSourceID: int = 1
	var groundAtlasCoordinate: Vector2i = Vector2i(2, 3)
	for cellPos in tileMap.get_used_cells_by_id(getLayerIDByName("Obstacle")):
		tileMap.set_cell(getLayerIDByName("Ground"), cellPos, groundSourceID, groundAtlasCoordinate)
	
	for cellPos in tileMap.get_used_cells_by_id(getLayerIDByName("Props")):
		tileMap.set_cell(getLayerIDByName("Ground"), cellPos, groundSourceID, groundAtlasCoordinate)

func getLayerIDByName(name: String) -> int:
	for layerID in tileMap.get_layers_count():
		if tileMap.get_layer_name(layerID) == name:
			return layerID
	return -1

func getCell(x, y, layerID) -> int:
	if tileMap.get_cell_source_id(layerID, Vector2i(x, y)) != -1: # if exist then 1
		return 1
	else:
		return 0
	
# maximum of 8 neighbors and mininum of 0
func checkNeighbors(x: int, y: int, layerID: int) -> int:
	var left = getCell(x-1, y-1, layerID) + getCell(x-1, y, layerID) + getCell(x-1, y+1, layerID)
	var topAndBottom = getCell(x, y+1, layerID) + getCell(x, y-1, layerID)
	var right = getCell(x+1, y-1, layerID) + getCell(x+1, y, layerID) + getCell(x+1, y+1, layerID)
	
	return left + topAndBottom + right

func recordValidEnemyPositions() -> void:
	var groundID: int = getLayerIDByName("Ground")
	
	for vector in tileMap.get_used_cells(groundID):
		var hasEightNeighbors: bool = checkNeighbors(vector.x, vector.y, groundID) == 8
		var notObstacleTile: bool = getCell(vector.x, vector.y, getLayerIDByName("Obstacle")) == 0
		var notPathTile: bool = getCell(vector.x, vector.y, getLayerIDByName("Path")) == 0
		
		if hasEightNeighbors and notObstacleTile and notPathTile:
			validEnemyLocations.append(tileMap.map_to_local(vector))

func recordValidPlayerPositions() -> void:
	var groundID: int = getLayerIDByName("Ground")
	var pathID: int = getLayerIDByName("Path")
	
	for vector in tileMap.get_used_cells(groundID):
		var hasEightNeighbors: bool = checkNeighbors(vector.x, vector.y, groundID) == 8
		var notObstacleTile: bool = getCell(vector.x, vector.y, getLayerIDByName("Obstacle")) == 0
		var adjacentPathTile: bool = checkNeighbors(vector.x, vector.y, pathID) >= 1
		
		if hasEightNeighbors and notObstacleTile and adjacentPathTile:
			validPlayerLocations.append(tileMap.map_to_local(vector))

func spawnEnemyAtRandomLocation() -> void:
	var randomLocation: Vector2 = validEnemyLocations[rng.randi_range(0, validEnemyLocations.size()-1)]
	var enemyInstance: CharacterBody2D = EnemyEntity.instantiate()
	enemyInstance.global_position = randomLocation
	add_child(enemyInstance)

# This function is meant to be called by player to wander
func returnValidPlayerLocation() -> Vector2:
	return validPlayerLocations[rng.randi_range(0, validPlayerLocations.size()-1)]

func updateUpgradeAvailability() -> void:
	if Global.playerExperience >= upgradeCost:
		$CanvasLayer/Control/BoxContainer/SpawnEnemyButton.disabled = false
	else:
		$CanvasLayer/Control/BoxContainer/SpawnEnemyButton.disabled = true

func _on_spawn_enemy_timeout():
	if getEnemyCount() < maxSpawnLimit:
		spawnEnemyAtRandomLocation()

func _on_spawn_enemy_button_pressed():
	print($SpawnEnemy.wait_time)
	if $SpawnEnemy.wait_time > 0.1 and Global.playerExperience >= upgradeCost:
#		$SpawnEnemy.stop()
		Global.playerExperience -= upgradeCost
		main.updateUI()
		upgradeCost += upgradeCost/2
		$SpawnEnemy.wait_time /= 1.2
		$CanvasLayer/Control/BoxContainer/SpawnEnemyButton.text = "upgrade enemy spawner\ncost: " + str(upgradeCost) + " PX\nspawn time: " + str("%.1f" % $SpawnEnemy.wait_time) + "s"
#		$SpawnEnemy.start()

		updateUpgradeAvailability()
