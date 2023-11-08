extends Node2D

@onready var tileMap = $TileMap

func _ready():
	for cellPos in tileMap.get_used_cells_by_id(getLayerIDByName("Water")):
		tileMap.set_cell(getLayerIDByName("Ground"), cellPos, -1)

func getLayerIDByName(name: String):
	for layerID in tileMap.get_layers_count():
		if tileMap.get_layer_name(layerID) == name:
			return layerID
	return -1
