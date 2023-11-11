extends Node2D

@onready var tileMap: TileMap = $TileMap
var validEnemyLocations: Array

var groundTerrainSet: int = 0

func _ready() -> void:
	replaceGroundFromObstacles()
	removeNonSurroundedGround()

func recordValidEnemyPositions() -> void:
	for cellPos in tileMap.get_used_cells_by_id(getLayerIDByName("Ground")):
		pass
		
func replaceGroundFromObstacles() -> void:
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
#	var left = grid[x-1][y-1] + grid[x-1][y] + grid[x-1][y+1]
	var left = getCell(x-1, y-1, layerID) + getCell(x-1, y, layerID) + getCell(x-1, y+1, layerID)
#	var topAndBottom = grid[x][y+1] + grid[x][y-1]
	var topAndBottom = getCell(x, y+1, layerID) + getCell(x, y-1, layerID)
#	var right = grid[x+1][y-1] + grid[x+1][y] + grid[x+1][y+1]
	var right = getCell(x+1, y-1, layerID) + getCell(x+1, y, layerID) + getCell(x+1, y+1, layerID)
	return left + topAndBottom + right

# must have 8 neighbors
func removeNonSurroundedGround() -> void:
	var groundID = getLayerIDByName("Ground")
	var tilesToRemove: Array = [] # array of vectors
	
	
	for vector in tileMap.get_used_cells(groundID):
		if checkNeighbors(vector.x, vector.y, groundID) != 8:
			tilesToRemove.append(vector)
	
	# Reason for separation: dont want cells to be removed and to use that as future neighboring checks
	for vector in tilesToRemove:
		tileMap.set_cell(groundID, vector, -1)
	
