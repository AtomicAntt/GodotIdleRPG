extends Node2D

@onready var tileMap: TileMap = $TileMap

@onready var EnemyEntity := preload("res://GameObjects/EnemyEntity.tscn")

var validEnemyLocations: Array # Array of vector2
var validPlayerLocations: Array # Array of vector2

var groundTerrainSet: int = 0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	# Reason for this function: Need to remove navigation from tiles where obstacles like water is present.
	replaceGroundAtObstacles()
	recordValidEnemyPositions()
	recordValidPlayerPositions()
	

func replaceGroundAtObstacles() -> void:
	var groundSourceID: int = 1
	var groundAtlasCoordinate: Vector2i = Vector2i(2, 3)
	for cellPos in tileMap.get_used_cells_by_id(getLayerIDByName("Obstacle")):
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
